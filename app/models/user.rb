class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable,
	# :timeoutable and :omniauthable
	# Also include https://github.com/Houdini/two_factor_authentication.
	devise :two_factor_authenticatable, :database_authenticatable, :registerable, :confirmable,
		:recoverable, :rememberable, :trackable, :validatable, :lockable, :omniauthable
	has_one_time_password encrypted: true
	
	before_create :skip_confirmation!, if: :claiming_profile?
	after_create :send_welcome_email, if: :claiming_profile?
	
	# Track changes to each user.
	# But ignore common events like sign-in to minimize versions data.
	has_paper_trail ignore: [:last_sign_in_at, :current_sign_in_at, :last_sign_in_ip, :current_sign_in_ip, :sign_in_count]
	
	# Setup accessible (or protected) attributes for your model
	PASSWORDLESS_ACCESSIBLE_ATTRIBUTES = [
		:provider_marketing_emails, :provider_newsletters,
		:parent_newsletters, :profile_help
	]
	PASSWORD_ACCESSIBLE_ATTRIBUTES = [
		*PASSWORDLESS_ACCESSIBLE_ATTRIBUTES,
		:email, :password, :password_confirmation, :current_password, :remember_me,
		:profile_attributes, :phone, :is_provider, :username, :registration_special_code,
		:signed_up_from_blog, :signed_up_for_mailing_lists, :postal_code
	]
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :email, :phone, :username, :postal_code

	has_one :profile # If we do "dependent: :destroy", it will be hard to detach or move the profile.
	accepts_nested_attributes_for :profile
	
	has_many :reviews_given, class_name: 'Review', foreign_key: :reviewer_id, dependent: :destroy
	has_many :ratings_given, class_name: 'Rating', foreign_key: :rater_id, dependent: :destroy
	
	serialize :roles, Array
	
	belongs_to :admin_confirmation_sent_by, class_name: 'User'
	
	has_one :stripe_info
	has_many :customers, through: :customer_files
	has_many :customer_files do
		def for_customer(customer)
			where(customer_id: customer).first
		end
	end
	has_one :as_customer, class_name: 'Customer'
	
	# Define minimum and/or maximum lengths of string and text attributes in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MIN_LENGTHS = {
		password: Devise.password_length.begin,
		username: UsernameValidator::MIN_LENGTH
	}
	MAX_LENGTHS = {
		email: EmailValidator::MAX_LENGTH,
		password: Devise.password_length.end,
		phone: PhoneNumberValidator::MAX_LENGTH,
		registration_special_code: 250,
		postal_code: 20,
		username: UsernameValidator::MAX_LENGTH
	}
	
	# Email format and password length are checked by Devise.
	# Username and phone lengths are checked by their own validators.
	# Note: Order of validation will determine display order of error messages.
	before_validation :validate_newsletter_subscription, if: Proc.new { |user| user.new_record? and user.signed_up_for_mailing_lists }
	validates :email, length: {maximum: MAX_LENGTHS[:email]}
	validates :username, username: true, allow_blank: true
	validates :username, uniqueness: { case_sensitive: false }, allow_blank: true
	validates :phone, phone_number: true, allow_blank: true
	[:postal_code, :registration_special_code].each do |attribute|
		validates attribute, length: { maximum: MAX_LENGTHS[attribute] }, allow_blank: true
	end
	validates *active_mailing_lists, email_subscription: true if active_mailing_lists.present?
	
	scope :order_by_id, -> { order('id') }
	scope :order_by_descending_id, -> { order('id DESC') }
	scope :order_by_email, -> { order('lower(email)') }

	after_save do
		# Create new or update/delete existing subscription.
		subscription_attr_updated = (changes.slice :email, :username)
		sync_subscription_preferences(subscription_attr_updated)
	end
	
	# Only used by single sign-on, so return as little information as possible.
	def as_json(options={})
		{
			email: email,
			first_name: (username.presence || I18n.t('views.user.view.no_name')),
			last_name: ''
		}
	end
	
	# Solr search configuration.
	# searchable do
	# 	text :email, :display_phone
	# end
	
	def username_or_email
		username.presence or email
	end
	
	def display_phone
		display_phone_number phone
	end
	
	def name_for_greeting
		profile.try(:first_name)
	end
	
	def add_role(role)
		roles << role.to_sym if role && !has_role?(role)
	end
	
	def remove_role(role)
		roles.delete role.to_sym
	end
	
	def has_role?(role=:undefined)
		roles.include? role.to_sym
	end
	
	def admin?
		has_role? :admin
	end
	
	def expert?
		has_role? :expert
	end
	
	def client?
		has_role? :client
	end
	
	def profile_editor?
		has_role?(:profile_editor) || has_role?(:admin)
	end
	
	def is_provider=(value)
		if value.present? && !client?
			add_role :expert
		elsif value.blank? && !expert?
			add_role :client
		end
		@is_provider = value
	end
	
	def is_provider
		@is_provider
	end
	
	alias :is_provider? :expert?
	
	# If this user is a provider, ensure that they have a published profile.
	# Do nothing if this user is in the process of claiming a profile.
	def load_profile
		if is_provider? and !profile and !claiming_profile?
			build_profile
			profile.is_published = true # is_published cannot be mass assigned, so assign it this way.
			profile.save
		end
		profile
	end
	
	def has_persisted_profile?
		!!profile.try(:persisted?)
	end
	
	# Is this user a provider with a profile and set up to receive payments?
	def is_payable?
		!!(is_provider? && profile.try(:allow_charge_authorizations) && stripe_info)
	end
	
	# This method declares that this user is in the process of claiming their profile.
	def claiming_profile!(token)
		@claim_token = token
	end
	
	# True if this user is in the process of claiming their profile.
	def claiming_profile?
		@claim_token.present?
	end
	
	# If we are in the process of claiming a profile, returns that profile.
	def profile_to_claim
		@profile_to_claim ||= claiming_profile? && Profile.find_claimable(@claim_token.to_s) || nil
	end
	
	# Attempt to attach the profile specified by the token.  The profile must not already be claimed.
	# This user must be a provider and must not already have a persistent profile.
	# If we are forcing, then any existing profile will be replaced.
	def claim_profile(token, force=false)
		is_provider? && (profile.nil? || profile.new_record? || force) && token.present? &&
			(profile_to_claim = Profile.find_claimable(token.to_s)) &&
			(self.profile = profile_to_claim) && save
	end
	
	def admin_confirmation_sent?
		!!admin_confirmation_sent_at
	end
	
	# The Devise message to be shown if this account is inactive.
	# If in private alpha, not confirmed yet, and we haven't sent the confirmation email yet, then their approval is pending.
	def inactive_message
		running_as_private_site? &&
			!confirmed? && admin_confirmation_sent_at.nil? ? :confirmation_not_sent : super
	end
	
	# True if we are not allowed to contact this user (most likely because they unsubscribed their email address).
	def contact_is_blocked?
		email.present? and ContactBlocker.find_by_email_ignore_case(email).present?
	end

	# Returns the name of the attribute that holds the user's leid (see below) for the given list.
	# Class method is convenient for queries where we don't have an instance yet.
	def self.leid_attr_name(list_name)
		list_name.to_s + '_leid'
	end
	# Instance method.
	def leid_attr_name(list_name)
		self.class.leid_attr_name list_name
	end
	
	# Returns this user's unique_email_id for the given list name.
	# unique_email_id is used by MailChimp to identify an email address across its systems.
	# Because a user can change the email address of the subscription via MailChimp, we can't
	# reliably use the user.email value to look up their subscription on MailChimp. But we can
	# use the unique_email_id.
	def leid(list_name)
		leid_attr = leid_attr_name list_name
		respond_to?(leid_attr) ? send(leid_attr) : nil
	end

	# True if this user is currently subscribed to the specified mailing list.
	def subscribed_to_mailing_list?(list_name)
		leid(list_name).present?
	end

	#Sync local subscriptions changes (create/update/delete) with MailChimp.
	def sync_subscription_preferences(updated_attrs=[])
		email_update = updated_attrs[:email]
		if email_update.present?
			if update_mailing_lists_in_background?
				delay.import_subscriptions
			else
				import_subscriptions
			end
		end
		old_values = active_mailing_lists.inject({}) do |list_values, list|
			list_values[list] = subscribed_to_mailing_list?(list)
			list_values
		end
		new_values = active_mailing_lists.inject({}) do |list_values, list|
			list_values[list] = send(list)
			list_values
		end
		
		subscriptions_to_update = old_values.merge(new_values){|key, ov, nv| ((!ov && nv) || (ov && nv && updated_attrs.any?))}.select {|k,v| v}.keys
		subscriptions_to_remove = old_values.merge(new_values){|key, ov, nv| (ov && !nv)}.select {|k,v| v}.keys

		if update_mailing_lists_in_background?
			delay.subscribe_to_mailing_lists(subscriptions_to_update, email_update)
			delay.unsubscribe_from_mailing_lists(subscriptions_to_remove)
		else
			subscribe_to_mailing_lists(subscriptions_to_update, email_update)
			unsubscribe_from_mailing_lists(subscriptions_to_remove)
		end
	end
	
	# Subscription terminated externally through MailChimp interface.
	# Updates user subscriptions to match external modifications.
	def process_unsubscribe_event(list_name)
		# List name is valid?
		return unless User.mailing_list_name_valid?(list_name)
		update_column(leid_attr_name(list_name), nil)
		update_column(list_name, false)
	end

	# Subscription created or updated externally (through web hook or rake task).
	# Persists new leid.
	def process_subscribe_event(list_name, leid)
		# List name is valid?
		return unless User.mailing_list_name_valid?(list_name)
		if read_attribute list_name
			update_column(leid_attr_name(list_name), leid)
		end
	end
	
	# Ensure that this user is not subscribed to any of our emails.
	# Assumes that the user will be unsubscribed from external mailing lists via callback(s).
	def remove_email_subscriptions
		active_mailing_lists.each do |list_name|
			write_attribute list_name, false
		end
		save!
	end
	
	# True if this user is a client of the given provider.
	def is_client_of?(provider)
		as_customer && provider ? as_customer.customer_files.for_provider(provider).present? : false
	end
	
	# True if this user is a customer of one or more paid providers.
	def has_paid_providers?
		as_customer.try(:customer_files).present?
	end
	
	def paid_providers
		as_customer.try(:customer_files).try(:map, &:provider).try(:compact).presence || []
	end
	
	# True if this user has one or more paying customers.
	def has_paying_customers?
		customer_files.present?
	end
	
	def paying_customers
		customer_files.map(&:customer).compact
	end
	
	def paying_users
		paying_customers.map(&:user).compact
	end
	
	def hexdigest(name='SHA224', key='NAFCaaKhrU2crEhU7kHbM7Yh73zntMzH')
		if persisted?
			OpenSSL::HMAC.hexdigest name, key, id.to_s
		end
	end

	def send_two_factor_authentication_code
		# use Model#otp_code and send via SMS, etc.
		logger.debug "User#otp_code=>#{otp_code}" if Rails.env.development?
	end
	
	def two_factor_authentication_allowed?
		(admin? or profile_editor?) and Devise.otp_secret_encryption_key.present?
	end
	
	def need_two_factor_authentication?(request)
		two_factor_authentication_allowed? and otp_secret_key.present?
	end
	
	def reset_otp_secret_key
		self.otp_secret_key = generate_totp_secret
	end
	
	# Public class methods.
	#
	# Includes methods whose behavior is identical in the superclass when not running as a private site,
	# I initially tried only defining the methods here when running_as_private_site? is true.
	# But then the methods were not defined in Rspec for private_site specs (the test environment caches classes).
	# You can fix this by reloading the User class in the private_site around hook, but that seemed risky.
	# So I think the more robust solution is to always define the methods here and check running_as_private_site?
	# within the method.  Bleh.
	class << self
		
		# Class method to find the first matching user by email address while ignoring case.
		def find_by_email_ignore_case(email)
			where('lower(email) = ?', email.strip.downcase).first
		end
	
		# Generate a password that is not too long.
		def generate_password
			gen = Random.new
			max = 1_000_000_000_000_000
			OpenSSL::HMAC.hexdigest('SHA224', gen.rand(max).to_s, gen.rand(max).to_s).slice(0, MAX_LENGTHS[:password])
		end
	
		def admin_approval_required(user)
			unless user.nil? || user.confirmed? || user.admin_confirmation_sent?
				user.errors.add(:admin_confirmation_sent_at, :confirmation_not_sent) if user.errors.blank?
				user
			else
				yield
			end
		end
		
		def send_confirmation_instructions(attributes={})
			user = if running_as_private_site? && !attributes[:admin_confirmation_sent_by_id]
				admin_approval_required(find_or_initialize_with_errors(confirmation_keys, attributes, :not_found)) do
					super
				end
			else
				super
			end
			if attributes[:admin_confirmation_sent_by_id] && user.errors.blank? && user.try(:persisted?)
				user.admin_confirmation_sent_by_id = attributes[:admin_confirmation_sent_by_id]
				user.admin_confirmation_sent_at = Time.now.utc
				user.save!
			end
			user
		end
	
		def confirm_by_token(confirmation_token)
			if running_as_private_site?
				encoded_token = Devise.token_generator.digest(self, :confirmation_token, confirmation_token)
				admin_approval_required(find_or_initialize_with_error_by(:confirmation_token, encoded_token)) do
					super
				end
			else
				super
			end
		end
	
		def send_reset_password_instructions(attributes={})
			if running_as_private_site?
				admin_approval_required(find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)) do
					super
				end
			else
				super
			end
		end
	
		def reset_password_by_token(attributes={})
			if running_as_private_site?
				encoded_token = Devise.token_generator.digest(self, :reset_password_token, attributes[:reset_password_token])
				admin_approval_required(find_or_initialize_with_error_by(:reset_password_token, encoded_token)) do
					super
				end
			else
				super
			end
		end
		
		# True if list name is one of predefined list names.
		def mailing_list_name_valid?(list_name)
			mailchimp_list_ids.has_key?(list_name)
		end

	end
	# End of public class methods.
	
	protected
	
	# A callback method used to deliver confirmation instructions on creation.
	# This overrides the Devise method to allow us to define our own email.
	def send_on_create_confirmation_instructions
		generate_confirmation_token! unless @raw_confirmation_token
		
		if signed_up_for_mailing_lists
			send_devise_notification :on_create_newsletter_confirmation_instructions, @raw_confirmation_token
		elsif signed_up_from_blog
			send_devise_notification :on_create_blog_confirmation_instructions, @raw_confirmation_token
		elsif is_provider?
			send_devise_notification :on_create_provider_confirmation_instructions, @raw_confirmation_token
		else
			send_devise_notification :on_create_confirmation_instructions, @raw_confirmation_token
		end
	end
	
	# A Devise callback that runs after the user confirms their email address.
	# This can happen as part of registration or if the user changed their email address.
	def after_confirmation
		send_welcome_email if is_provider?
	end
	
	private
	
	# Delivers a welcome email that is intended for a newly registered user.
	# Sets welcome_sent_at to the delivery time. This attribute is used to prevent duplicate deliveries.
	def send_welcome_email
		unless welcome_sent_at
			send_devise_notification :on_create_welcome
			update_column :welcome_sent_at, Time.now.utc
		end
	end
	
	# Do validation required by a registration event that is mainly for subscribing to our newsletter.
	def validate_newsletter_subscription
		unless (active_mailing_lists.inject(false) { |subscribed, list| subscribed or read_attribute(list) })
			errors.add :base, :newsletter_edition_not_selected
		end
	end
	
	# def validate_username?
	# 	new_record? or username_changed?
	# end

	# Creates new or updates existing subscriptions on MailChimp.
	def subscribe_to_mailing_lists(list_names=[], email_update=nil)
		# Do nothing if we are not allowed to contact this user. (It's OK if they are not confirmed yet.)
		return false if contact_is_blocked?

		merge_vars = { 'SUBSOURCE' => 'directory_user_create_or_update' }
		if expert?
			first_name = profile.try(:first_name).try(:strip).presence || ''
			last_name  = profile.try(:last_name).try(:strip).presence || ''
			merge_vars.merge! FNAME: first_name, LNAME: last_name
		end
		
		list_names.each do |list_name|
			next if !User.mailing_list_name_valid?(list_name)

			list_id = mailchimp_list_ids[list_name]
			
			r = nil
			
			# have to deal with case where they changed the email address while subscribed, i.e., email_update is present; in this case, we must use the previous email address for the MD5 hash.
			begin
				if email_update.present?
					# Update the email address in the subscription with the old email address.
					old_email = email_update[0]
					r = Gibbon::Request.lists(list_id).members(email_md5_hash(old_email)).update body: {
						email_address: email,
						status: 'subscribed',
						merge_fields: merge_vars
					}
				end
			rescue Gibbon::MailChimpError => e
				logger.error "MailChimp error while updating subscription for user #{id} to #{list_name} with email #{old_email}: #{e.title}; #{e.detail}; status: #{e.status_code}; new email: #{email}" unless e.status_code == 404
			end
			
			begin
				unless r.present? and r['status'] == 'subscribed'
					r = Gibbon::Request.lists(list_id).members(email_md5_hash(email)).upsert body: {
						email_address: email,
						status: 'subscribed',
						merge_fields: merge_vars
					}
				end
			rescue Gibbon::MailChimpError => e
				logger.error "MailChimp error while subscribing user #{id} to #{list_name}: #{e.title}; #{e.detail}; status: #{e.status_code}; email: #{email}"
			end

			if r.present? and r['status'] == 'subscribed'
				update_column(list_name.to_s, true)
				update_column(leid_attr_name(list_name), r['unique_email_id'])
			end
		end
	end

	# Removes user from specified mailing lists on MailChimp.
	def unsubscribe_from_mailing_lists(list_names=[])
		list_names.each do |list_name|
			next if !User.mailing_list_name_valid?(list_name)
			
			list_id = mailchimp_list_ids[list_name]
			
			begin
				email_hash = email_md5_hash(email)
				Gibbon::Request.lists(list_id).members(email_hash).update body: {
					status: 'unsubscribed'
				}
				update_column(leid_attr_name(list_name), nil)
			rescue Gibbon::MailChimpError => e
				if e.status_code == 404 && leid(list_name)
					# Not found by email address; try leid (MailChimp's unique_email_id).
					begin
						r = Gibbon::Request.lists(list_id).members.retrieve params: {
							unique_email_id: leid(list_name)
						}
						if member = r['members'].first
							email_hash = email_md5_hash(member['email_address'])
							Gibbon::Request.lists(list_id).members(email_hash).update body: {
								status: 'unsubscribed'
							}
							update_column(leid_attr_name(list_name), nil)
						else
							logger.error "MailChimp error while unsubscribing user #{id}: could not find subscription via MailChimp API with email => #{email} or leid => #{leid(list_name)}"
						end
					rescue Gibbon::MailChimpError => e
						logger.error "MailChimp error while unsubscribing user #{id}: #{e.title}; #{e.detail}; status: #{e.status_code}; email: #{email}; leid: #{leid(list_name)}"
					end
				else
					logger.error "MailChimp error while unsubscribing user #{id}: #{e.title}; #{e.detail}; status: #{e.status_code}; email: #{email}; leid: #{leid(list_name)}"
				end
			end
		end
	end

	# Checks for existing subscriptions on MailChimp and updates user subscription preferences accordingly
	def import_subscriptions
		active_mailing_lists.each do |list_name|
			list_id = mailchimp_list_ids[list_name]
			
			begin
				r = Gibbon::Request.lists(list_id).members(email_md5_hash(email)).retrieve
				if r.present? && r['status'] == 'subscribed'
					update_column(list_name.to_s, true)
					update_column(leid_attr_name(list_name), r['unique_email_id'])
				end
			rescue Gibbon::MailChimpError => e
				logger.error "MailChimp error while importing mailchimp subscriptions for user #{id}: #{e.title}; #{e.detail}; status: #{e.status_code}; email: #{email}" unless e.status_code == 404 # 404 means no subscription record, i.e., not subscribed.
			end
		end
	end
end
