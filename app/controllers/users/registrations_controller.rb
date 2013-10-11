class Users::RegistrationsController < Devise::RegistrationsController
	# Add this controller to the devise route if you need to customize the registration controller.
	
	before_filter :before_registration, only: :create
	after_filter :after_registration, only: :create
	
	# User settings page should not be cached because it might display sensitive information.
	after_filter :set_no_cache_response_headers, only: [:edit, :update]

	protected

	# Override build_resource method in superclass.
	# This override allows us to pre-build the resource before the create action is executed.
	def build_resource(hash=nil)
		super unless resource
	end

	private

	# Note: session[:claiming_profile] was set to the token by lib/custom_authentication_failure_app.rb.
	def before_registration
		if session[:claiming_profile].present?
			build_resource sign_up_params
			resource.claiming_profile! session[:claiming_profile]
		end
	end
	
	def after_registration
		if resource && resource.errors.empty?
			# Ensure user is a client if nothing else.
			if resource.roles.blank?
				resource.add_role :client
				resource.save!
			end
		end
	end

	# The URL to be used after updating a resource.
	# If I'm a provider, go to my profile page, otherwise go to the home page.
	def after_update_path_for(resource)
		resource.is_provider? && can?(:view_my_profile, resource.profile) ? my_profile_path : signed_in_root_path(resource)
	end
end
