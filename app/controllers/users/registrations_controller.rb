class Users::RegistrationsController < Devise::RegistrationsController
	# Add this controller to the devise route if you need to customize the registration controller.
	
	after_filter :after_registration, :only => [:create], :if => "resource.errors.empty?"

	private

	def after_registration
		# Ensure user is a client if nothing else.
		resource.add_role :client if resource.roles.blank?
		resource.save!
	end

	# The URL to be used after updating a resource.
	# If I'm a provider, go to my profile page, otherwise go to the home page.
	def after_update_path_for(resource)
		resource.is_provider? && can?(:view_my_profile, resource.profile) ? my_profile_path : signed_in_root_path(resource)
	end
end
