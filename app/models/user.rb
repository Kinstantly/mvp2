class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable,
	# :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :confirmable,
		:recoverable, :rememberable, :trackable, :validatable, :lockable, :omniauthable
	
	before_create :skip_confirmation!, if: :claiming_profile?
	after_create :send_welcome_email, if: :claiming_profile?
	
	# Track changes to each user.
	# But ignore common events like sign-in to minimize versions data.
	has_paper_trail ignore: [:last_sign_in_at, :current_sign_in_at, :last_sign_in_ip, :current_sign_in_ip, :sign_in_count]
	
	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, 
		:profile_attributes, :phone, :is_provider, :username, :registration_special_code, :profile_help,
		:parent_marketing_emails, :parent_newsletters, :provider_marketing_emails, :provider_newsletters
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :email, :phone, :username

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
		username: UsernameValidator::MAX_LENGTH
	}
	
	# Email format and password length are checked by Devise.
	# Username and phone lengths are checked by their own validators.
	validates :email, length: {maximum: MAX_LENGTHS[:email]}
	validates :username, username: true, if: :validate_username?
	validates :username, uniqueness: { case_sensitive: false }, if: 'username.present?'
	validates :phone, phone_number: true, allow_blank: true
	validates :registration_special_code, length: {maximum: MAX_LENGTHS[:registration_special_code]}
	validates :parent_marketing_emails, :parent_newsletters, :provider_marketing_emails, :provider_newsletters, email_subscription: true
	
	scope :order_by_id, order('id')
	scope :order_by_descending_id, order('id DESC')
	scope :order_by_email, order('lower(email)')

	after_save do
		# Create new or update/delete existing subscription.
		subscription_attr_updated = (changes.slice :email, :username)
		sync_subscription_preferenses(subscription_attr_updated)
	end
	
	# Solr search configuration.
	# searchable do
	# 	text :email, :display_phone
	# end
	
	def validate_username?
		client? or username.present?
	end
	
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
		email.present? and ContactBlocker.find_by_email(email).present?
	end

	# List names with corresponding list-email ids (leid).
	# Leids are used by MailChimp to identify user on a mailing list.
	def leids
		{ parent_marketing_emails: parent_marketing_emails_leid,
			parent_newsletters: parent_newsletters_leid,
			provider_marketing_emails: provider_marketing_emails_leid,
			provider_newsletters: provider_newsletters_leid }
	end

	# True if this user is currently subscribed to a mailing list.
	def subscribed_to_mailing_list?(list_name)
		leids[list_name].present?
	end

	#Sync subscriptions (create/update/delete) with MailChimp.
	def sync_subscription_preferenses(updated_attrs=[])
		old_values = {
			parent_marketing_emails: subscribed_to_mailing_list?(:parent_marketing_emails),
			parent_newsletters: subscribed_to_mailing_list?(:parent_newsletters),
			provider_marketing_emails: subscribed_to_mailing_list?(:provider_marketing_emails),
			provider_newsletters: subscribed_to_mailing_list?(:provider_newsletters)
		}
		new_values = {
			parent_marketing_emails: parent_marketing_emails,
			parent_newsletters: parent_newsletters,
			provider_marketing_emails: provider_marketing_emails,
			provider_newsletters: provider_newsletters
		}
		
		subscriptions_to_update = old_values.merge(new_values){|key, ov, nv| ((!ov && nv) || (ov && nv && updated_attrs.any?))}.select {|k,v| v}.keys
		subscriptions_to_remove = old_values.merge(new_values){|key, ov, nv| (ov && !nv)}.select {|k,v| v}.keys

		if Rails.env.production?
			delay.subscribe_to_mailing_lists(subscriptions_to_update, updated_attrs[:email].present?)
			delay.unsubscribe_from_mailing_lists(subscriptions_to_remove)
		else
			subscribe_to_mailing_lists(subscriptions_to_update, updated_attrs[:email].present?)
			unsubscribe_from_mailing_lists(subscriptions_to_remove)
		end
	end
	
	# Subscription terminated externally through MailChimp interface.
	# Updates user subscriptions to match external modifications.
	def process_unsubscribe_event(list_name)
		# List name is valid?
		return unless User.mailing_list_name_valid?(list_name)
		update_column("#{list_name}_leid", nil)
		update_column(list_name, false)
	end

	# Subscription created externally (through rake task).
	# Persists new leid.
	def process_subscribe_event(list_name, leid)
		# List name is valid?
		return unless User.mailing_list_name_valid?(list_name)
		if read_attribute list_name
			update_column("#{list_name}_leid", leid)
		end
	end
	
	# Ensure that this user is not subscribed to any of our emails.
	# Assumes that the user will be unsubscribed from external mailing lists via callback(s).
	def remove_email_subscriptions
		self.parent_marketing_emails = false
		self.parent_newsletters = false
		self.provider_marketing_emails = false
		self.provider_newsletters = false
		save!
	end
	
	# True if this user is a client of the given provider.
	def is_client_of?(provider)
		as_customer && provider ? as_customer.customer_files.for_provider(provider).present? : false
	end

	# Public class methods.
	#
	# For methods whose behavior is identical in the superclass when not running as a private site,
	# I initially tried only defining the methods here when running_as_private_site? is true.
	# But then the methods were not defined in Rspec for private_site specs (the test environment caches classes).
	# You can fix this by reloading the User class in the private_site around hook, but that seemed risky.
	# So I think the more robust solution is to always define the methods here and check running_as_private_site?
	# within the method.  Bleh.
	class << self
		
		# Generate a password that is not too long.
		def generate_password
			generate_token('encrypted_password').slice(0, MAX_LENGTHS[:password])
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
			user = if running_as_private_site? && !attributes[:admin_mode]
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
				admin_approval_required(find_or_initialize_with_error_by(:confirmation_token, confirmation_token)) do
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
				admin_approval_required(find_or_initialize_with_error_by(:reset_password_token, attributes[:reset_password_token])) do
					super
				end
			else
				super
			end
		end
		
		# True if list name is one of predefined list names.
		def mailing_list_name_valid?(list_name)
			Rails.configuration.mailchimp_list_id.has_key?(list_name)
		end

	end
	# End of public class methods.
	
	protected
	
	# A callback method used to deliver confirmation instructions on creation.
	# This overrides the Devise method to allow us to define our own email.
	def send_on_create_confirmation_instructions
		if is_provider?
			send_devise_notification :on_create_provider_confirmation_instructions
		else
			send_devise_notification :on_create_confirmation_instructions
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
	
	# Creates new or updates existing subscriptions on MailChimp.
	def subscribe_to_mailing_lists(list_names=[], new_email=false)
		# Do nothing if this user is not confirmed or we are not allowed to contact them.
		return false if !confirmed? or contact_is_blocked?

		first_name = username.presence || email.presence
		last_name  = ''
		if expert?
			if profile.first_name.present?
				first_name = profile.first_name
				last_name  = profile.last_name if profile.last_name.present?
			end
		end
		merge_vars = { FNAME: first_name, LNAME: last_name }
		
		list_names.each do |list_name|
			next if !User.mailing_list_name_valid?(list_name)

			list_id = Rails.configuration.mailchimp_list_id[list_name]
			subscriber_leid = leids[list_name]
			email_struct = { leid: subscriber_leid }
			if new_email && subscriber_leid.present?
				# User changed their email; email attribute have been updated at this time.
				# Do not use email as an id, but instruct MailChimp to update the email.
				merge_vars['new-email'] = email
			else
				email_struct[:email] = email
			end
			begin
				gb = Gibbon::API.new
				r = gb.lists.subscribe id: list_id, 
					email: email_struct,
					merge_vars: merge_vars,
					double_optin: false,
					update_existing: true
				if r.present?
					update_column("#{list_name}_leid", r['leid'])
				end
			rescue Gibbon::MailChimpError => e
				logger.error "MailChimp error while subscribing user #{id} to #{merge_vars}: #{e.message}, error code: #{e.code}" if logger
			end
		end
	end

	# Removes user from specified mailing lists on MailChimp.
	def unsubscribe_from_mailing_lists(list_names=[])
		list_names.each do |list_name|
			next if !User.mailing_list_name_valid?(list_name)
			
			list_id = Rails.configuration.mailchimp_list_id[list_name]
			subscriber_leid = leids[list_name]
			email_struct = {email: email, leid: subscriber_leid}
			begin
				gb = Gibbon::API.new
				r = gb.lists.unsubscribe id: list_id, 
					email: email_struct,
					delete_member: true,
					send_goodbye: false,
					send_notify: false
				update_column("#{list_name}_leid", nil)
			rescue Gibbon::MailChimpError => e
				logger.error "MailChimp error while unsubscribing user #{id}: #{e.message}, error code: #{e.code}" if logger
			end
		end
	end
end
