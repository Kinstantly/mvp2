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
	
	has_many :ratings_given, class_name: 'Rate', foreign_key: :rater_id
	
	serialize :roles, Array
	
	validates :username, presence: true, if: 'client?'
	validates :username, length: {minimum: 4}, if: 'client? && username.present?'
	validates :phone, phone_number: true, allow_blank: true
	
	# Solr search configuration.
	# searchable do
	# 	text :email, :display_phone
	# end
	
	def display_phone
		display_phone_number phone
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
end
