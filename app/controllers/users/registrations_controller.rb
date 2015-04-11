class Users::RegistrationsController < Devise::RegistrationsController
	# Add this controller to the devise route if you need to customize the registration controller.

	before_filter :before_registration, only: :create
	after_filter :after_registration, only: :create
	
	# User settings page should not be cached because it might display sensitive information.
	after_filter :set_no_cache_response_headers, only: [:edit, :update]

	layout :registrations_layout

	def in_blog_new
		new
	end

	def edit
		if params[:contact_preferences].present?
			# Send to email subscription preferences.
			redirect_to(edit_subscriptions_url)
		else
			super
		end
	end

	# POST /resource
	def create
		build_resource(sign_up_params)

		if resource.save
			if resource.active_for_authentication?
				set_flash_message :notice, :signed_up if is_navigational_format?
				sign_up(resource_name, resource)
				respond_with resource, :location => after_sign_up_path_for(resource)
			else
				set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
				expire_session_data_after_sign_in!
				respond_with resource, :location => after_inactive_sign_up_path_for(resource)
			end
		else
			clean_up_passwords resource
			if params[:in_blog].present?
				render :in_blog_new
			else
				render :new
			end
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
		end
		# Flags that tell the views whether this registration is primarily a newsletter or blog sign-up from the user's perspective.
		@signing_up_from_blog = resource.signed_up_from_blog
		@signing_up_for_newsletter = resource.signed_up_for_mailing_lists
		flash[:after_sign_in_path_override] = edit_subscriptions_path if @signing_up_for_newsletter
	end
	
	# Called if we're already signed in and thus no registration is required.
	# If we were trying to get to newsletter sign-up, go to contact preferences instead.
	def require_no_authentication
		flash[:after_sign_in_path_override] = edit_subscriptions_path if params[:nlsub].present?
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
	# Go to the account settings page.
	def after_update_path_for(resource)
		edit_user_registration_path
	end

	def after_inactive_sign_up_path_for(resource)
		if params[:in_blog].present?
			in_blog_awaiting_confirmation_path
		else
			member_awaiting_confirmation_path
		end
	end

	def after_sign_up_error_path_for(resource)
		if params[:in_blog].present?
			in_blog_sign_up_path(resource)
		else
			new_user_registration_path(resource)
		end
	end

	# True if the request is for a sign-up that is embedded on the blog.
	# Checks for the in_blog the parameter (i.e. unsuccessful create action with in-blog signup).
	def request_in_blog?
		params[:in_blog].present? || ['in_blog_new', 'in_blog_awaiting_confirmation'].include?(action_name)
	end
	
	def registrations_layout
		# Use iframe_layout if in_blog present (i.e. unsuccessful create action with in-blog signup)
		request_in_blog? ? 'iframe_layout' : 'interior'
	end
	
	# Set exceptions to default values of the security-related HTTP headers in the response.
	# See https://www.owasp.org/index.php/List_of_useful_HTTP_headers
	# http://tools.ietf.org/html/rfc7034
	# http://www.w3.org/TR/CSP/#frame-src
	def set_default_response_headers
		super
		if response && request && request_in_blog?
			# Embed only on the blog site.
			allowed_url = blog_url
			referrer = request.headers['Referer']
			if referrer && (referrer.start_with?(allowed_url) || referrer.start_with?(root_url))
				existing_csp = response.headers['Content-Security-Policy']
				new_csp = "frame-src #{allowed_url}"
				response.headers.merge!({
					'Content-Security-Policy' => [existing_csp, new_csp].compact.join('; '),
					'X-Frame-Options' => "ALLOW-FROM #{allowed_url}"
				})
			end
		end
	end
end
