class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable,
	# :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :confirmable,
		:recoverable, :rememberable, :trackable, :validatable, :lockable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, 
		:profile_attributes, :phone, :is_provider, :username

	has_one :profile # If we do "dependent: :destroy", it will be hard to detach or move the profile.
	accepts_nested_attributes_for :profile
	
	has_many :reviews_given, class_name: 'Review', foreign_key: :reviewer_id
	has_many :ratings_given, class_name: 'Rating', foreign_key: :rater_id
	
	serialize :roles, Array
	
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
	end
	
	alias :is_provider? :expert?
	
	def has_persisted_profile?
		!!profile.try(:persisted?)
	end
	
	# Attempt to attach the profile specified by the token.  The profile must not already be claimed.
	# This user must be a provider and must not already have a persistent profile.
	# If we are forcing, then any existing profile will be replaced.
	def claim_profile(token, force=false)
		is_provider? && (profile.nil? || profile.new_record? || force) && token.present? &&
			(profile_to_claim = Profile.find_by_invitation_token(token.to_s)) && !profile_to_claim.claimed? &&
			(self.profile = profile_to_claim) && save
	end
	
	# Generate a password that is not too long.
	def self.generate_password
		generate_token('encrypted_password').slice(0, MAX_LENGTHS[:password])
	end
	
	protected
	
	# A callback method used to deliver confirmation instructions on creation.
	# This overrides the Devise method to map to a nice welcome e-mail.
	def send_on_create_confirmation_instructions
		send_devise_notification(:on_create_confirmation_instructions)
	end
end
