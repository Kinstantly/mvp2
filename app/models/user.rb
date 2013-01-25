class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable,
	# :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable, :lockable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, 
		:profile_attributes, :phone, :is_provider
	# attr_accessible :title, :body

	has_one :profile, dependent: :destroy
	accepts_nested_attributes_for :profile
	
	serialize :roles, Array
	
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
		add_role :expert if value.presence && !client?
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
