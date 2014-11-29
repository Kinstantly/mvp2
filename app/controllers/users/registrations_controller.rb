class Users::RegistrationsController < Devise::RegistrationsController
	# Add this controller to the devise route if you need to customize the registration controller.
	
	before_filter :before_registration, only: :create
	after_filter :after_registration, only: :create
	
	# User settings page should not be cached because it might display sensitive information.
	after_filter :set_no_cache_response_headers, only: [:edit, :update]

	layout :registrations_layout

	def edit
		if params[:contact_preferences].present?
			# The fragment ID is not preserved across a sign-in, so fake it with a query parameter.  :(
			redirect_to(edit_user_registration_url + '#contact_preferences')
		else
			super
		end
	end

	protected

	# Override build_resource method in superclass.
	# This override allows us to pre-build the resource before the create action is executed.
	# It also allows us to configure the resource before it is used.
	def build_resource(hash=nil)
		super unless resource
		
		# During private alpha, registrants are screened. Don't send them the confirmation link until they've pass screening.
		# The exception is someone we've invited to claim their profile.
		resource.skip_confirmation_notification! if running_as_private_site? && !resource.profile_to_claim
		
		# If the blog parameter is present, set resource.signed_up_from_blog to true, otherwise preserve its current value.
		if params[:blog].present? && resource.new_record?
			resource.signed_up_from_blog = true
			session[:signed_up_from_blog] = true # Needed for pre-confirmation phase because we're not signed in.
			if params[:rp].present?
				clean_path = params[:rp].sub(%r|https?://[^/]+/|, '').sub(%r|[/?].*|, '')
				session[:after_confirmation_url] = blog_url + clean_path
			else
				session[:after_confirmation_url] = blog_url
			end
		end
		# If the newsletter subscription parameter is present, set resource.signed_up_for_mailing_lists to true, otherwise preserve its current value.
		if params[:nlsub].present? && resource.new_record?
			resource.signed_up_for_mailing_lists = true
			session[:signed_up_for_mailing_lists] = true # Needed for pre-confirmation phase because we're not signed in.
			session[:after_confirmation_url] ||= root_path
		end
		# Flags that tell the views whether this registration is primarily a newsletter or blog sign-up from the user's perspective.
		@signing_up_from_blog = resource.signed_up_from_blog
		@signing_up_for_newsletter = resource.signed_up_for_mailing_lists
		session[:after_sign_in_path_override] = edit_user_registration_path + '#contact_preferences' if @signing_up_for_newsletter
	end
	
	# Called if we're already signed in and thus no registration is required.
	# If we were trying to get to newsletter sign-up, go to contact preferences instead.
	def require_no_authentication
		session[:after_sign_in_path_override] = edit_user_registration_path + '#contact_preferences' if params[:nlsub].present?
		super
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
			# Create profile if needed.
			resource.load_profile
			# Notify admin that either a provider or parent has registered.
			if resource.is_provider?
				AdminMailer.provider_registration_alert(resource).deliver
			else
				AdminMailer.parent_registration_alert(resource).deliver
			end
		end
	end

	# The URL to be used after updating a resource.
	# If I'm a provider, go to my profile page, otherwise go to the home page.
	def after_update_path_for(resource)
		if resource.is_provider? && can?(:view_my_profile, resource.profile)
			my_profile_path
		else
			signed_in_root_path resource
		end
	end

	def after_inactive_sign_up_path_for(resource)
		member_awaiting_confirmation_path
	end
	
	def registrations_layout
		['new', 'create'].include?(action_name) ? 'interior' : 'interior'
	end
	
	# Set exceptions to default values of the security-related HTTP headers in the response.
	# See https://www.owasp.org/index.php/List_of_useful_HTTP_headers
	def set_default_response_headers
		super
		response.headers.merge!({
			'X-Frame-Options' => "ALLOW-FROM: #{blog_url}"
		}) if response
	end
end
