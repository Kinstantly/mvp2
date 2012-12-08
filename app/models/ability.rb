class Ability
	include CanCan::Ability

	def initialize(user)
		user ||= User.new # guest user (not logged in)
		
		# The public can read published profiles.
		can :read, Profile, is_published: true
		
		# Experts should only be able to edit their profile via nested attributes on the user model.
		# This makes it safer to allow other roles to manage profiles directly via the profiles_controller.
		if user.expert?
			alias_action :view_profile, :edit_profile, :update_profile, to: :manage_profile
			can :manage_profile, User, id: user.id
			can :create, User, id: user.id
			can :update, User, id: user.id
			can :show, User, id: user.id
		end
		
		can :manage, Profile if user.profile_editor?
		
		can :manage, :all if user.admin?
		
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
