class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable,
	# :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :confirmable,
		:recoverable, :rememberable, :trackable, :validatable, :lockable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, 
		:profile_attributes, :phone, :is_provider, :username

	has_one :profile, dependent: :destroy
	accepts_nested_attributes_for :profile
	
	serialize :roles, Array
	
	validates :username, presence: true, if: 'client?'
	validates :username, length: {minimum: 4}, if: 'client? && username.present?'
	
	# Solr search configuration.
	searchable do
		text :email, :phone
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
	
	# Attempt to attach the profile specified by the token.  The profile must not already be claimed.
	# This user must be a provider and must not already have a persistent profile.
	def claim_profile(token)
		is_provider? && (profile.nil? || profile.new_record?) && token.present? &&
			(profile_to_claim = Profile.find_by_invitation_token(token)) && !profile_to_claim.claimed? &&
			(self.profile = profile_to_claim) && save
	end
end
