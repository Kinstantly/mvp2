class Ability
	include CanCan::Ability
	
	include SiteConfigurationHelpers
	
	def initialize(user)
		user ||= User.new # guest user (not logged in)
		
		# Alias for creating or updating.
		alias_action :create, :update, to: :save
		
		# The public and crawlers can view published profiles (but not the index because it shows full profiles).
		alias_action :show, :show_claiming, :link_index, :rating_score, to: :view
		can :view, Profile, is_published: true
		
		# When running as a private site and not signed in, can only show publicly published profiles.
		if running_as_private_site? and !user.confirmed?
			cannot :view, Profile
			can :show, Profile, is_published: true, public_on_private_site: true
		end
		
		# Any confirmed user can rate a published profile that is not their own.
		alias_action :edit_rating, to: :rate
		can :rate, Profile, is_published: true if user.confirmed?
		cannot :rate, Profile, user_id: user.id
		
		# Any confirmed user can create a review of a published profile.
		# However, a provider cannot review themself.
		can :create, Review if user.confirmed?
		cannot :create, Review, profile: { is_published: [false, nil] }
		cannot :create, Review, profile: { user_id: user.id }
		
		# The public can suggest providers.
		can :create, ProviderSuggestion

		# Experts should only be able to edit the profile attached to their user.
		# This makes it safer to allow other roles to manage profiles directly via the profiles_controller.
		# But don't allow expert to view or edit their profile via the users_controller, because it is too permissive.
		if user.expert?
			alias_action :claim_profile, :force_claim_profile, to: :claim_my_profile
			can :claim_my_profile, User, id: user.id
			can :create, User, id: user.id
			can :update, User, id: user.id
			can :show, User, id: user.id
			alias_action :view_my_profile, :edit_my_profile, :formlet_update, :photo_update, :services_info, :show_tab, :edit_tab, to: :manage_my_profile
			can :manage_my_profile, Profile, user_id: user.id
		end
		
		# Profile editors can do anything to profiles, except remove a claimed profile.
		if user.profile_editor?
			can :manage, Profile
			cannot :destroy, Profile
			can :destroy, Profile, user: nil
		end
		
		# Administrators can do anything, except remove a claimed profile.
		if user.admin?
			can :any, :admin
			can :manage, :all
			cannot :destroy, Profile
			can :destroy, Profile, user: nil
		end
		
		# Define abilities for the passed in user here. For example:
		#
		#		user ||= User.new # guest user (not logged in)
		#		if user.admin?
		#			can :manage, :all
		#		else
		#			can :read, :all
		#		end
		#
		# The first argument to `can` is the action you are giving the user permission to do.
		# If you pass :manage it will apply to every action. Other common actions here are
		# :read, :create, :update and :destroy.
		#
		# The second argument is the resource the user can perform the action on. If you pass
		# :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
		#
		# The third argument is an optional hash of conditions to further filter the objects.
		# For example, here the user can only update published articles.
		#
		#		can :update, Article, :published => true
		#
		# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
	end
end
