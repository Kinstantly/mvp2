class Ability
	include CanCan::Ability

	def initialize(user)
		user ||= User.new # guest user (not logged in)
		
		# The public and crawlers can view published profiles (but not the index because it shows full profiles).
		alias_action :show, :link_index, :rating_score, to: :view
		can :view, Profile, is_published: true
		
		# Any confirmed user can rate a published profile that is not their own.
		can :rate, Profile, is_published: true if user.confirmed_at
		cannot :rate, Profile, user_id: user.id
		
		# Experts should only be able to edit their profile via nested attributes on the user model.
		# This makes it safer to allow other roles to manage profiles directly via the profiles_controller.
		if user.expert?
			alias_action :view_profile, :edit_profile, :update_profile, :claim_profile, to: :manage_profile
			can :manage_profile, User, id: user.id
			can :create, User, id: user.id
			can :update, User, id: user.id
			can :show, User, id: user.id
		end
		
		if user.profile_editor?
			can :manage, Profile
			cannot :destroy, Profile
		end
		
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
