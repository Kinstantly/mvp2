class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable,
	# :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :confirmable,
		:recoverable, :rememberable, :trackable, :validatable, :lockable
	
	before_create :skip_confirmation!, if: :claiming_profile?
	after_create :send_welcome_email, if: :claiming_profile?
	
	# Track changes to each user.
	# But ignore common events like sign-in to minimize versions data.
	has_paper_trail ignore: [:last_sign_in_at, :current_sign_in_at, :last_sign_in_ip, :current_sign_in_ip, :sign_in_count]
	
	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, 
		:profile_attributes, :phone, :is_provider, :username
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :email, :phone, :username

	has_one :profile # If we do "dependent: :destroy", it will be hard to detach or move the profile.
	accepts_nested_attributes_for :profile
	
	has_many :reviews_given, class_name: 'Review', foreign_key: :reviewer_id, dependent: :destroy
	has_many :ratings_given, class_name: 'Rating', foreign_key: :rater_id, dependent: :destroy
	
	serialize :roles, Array
	
	belongs_to :admin_confirmation_sent_by, class_name: 'User'
	
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
		username: UsernameValidator::MAX_LENGTH
	}
	
	# Email format and password length are checked by Devise.
	# Username and phone lengths are checked by their own validators.
	validates :email, length: {maximum: MAX_LENGTHS[:email]}
	validates :username, username: true, if: :validate_username?
	validates :username, uniqueness: { case_sensitive: false }, if: 'username.present?'
	validates :phone, phone_number: true, allow_blank: true
	
	scope :order_by_id, order('id')
	scope :order_by_descending_id, order('id DESC')
	scope :order_by_email, order('lower(email)')
	
	# Solr search configuration.
	# searchable do
	# 	text :email, :display_phone
	# end
	
	def validate_username?
		client? or username.present?
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
		Rails.configuration.running_as_private_site &&
			!confirmed? && admin_confirmation_sent_at.nil? ? :confirmation_not_sent : super
	end
	
	# Public class methods.
	#
	# For methods whose behavior is identical in the superclass when not running as a private site,
	# I initially tried only defining the methods here when running_as_private_site is true.
	# But then the methods were not defined in Rspec for private_site specs (the test environment caches classes).
	# You can fix this by reloading the User class in the private_site around hook, but that seemed risky.
	# So I think the more robust solution is to always define the methods here and check running_as_private_site
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
			user = if Rails.configuration.running_as_private_site && !attributes[:admin_mode]
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
			if Rails.configuration.running_as_private_site
				admin_approval_required(find_or_initialize_with_error_by(:confirmation_token, confirmation_token)) do
					super
				end
			else
				super
			end
		end
	
		def send_reset_password_instructions(attributes={})
			if Rails.configuration.running_as_private_site
				admin_approval_required(find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)) do
					super
				end
			else
				super
			end
		end
	
		def reset_password_by_token(attributes={})
			if Rails.configuration.running_as_private_site
				admin_approval_required(find_or_initialize_with_error_by(:reset_password_token, attributes[:reset_password_token])) do
					super
				end
			else
				super
			end
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
end
