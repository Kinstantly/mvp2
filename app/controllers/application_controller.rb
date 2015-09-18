class ApplicationController < ActionController::Base
	
	include SiteConfigurationHelpers
	
	protect_from_forgery
	layout 'interior'
	
	http_basic_authenticate_with name: ENV['BASIC_AUTH_NAME'], password: ENV['BASIC_AUTH_PASSWORD'], unless: :skip_http_basic_authentication if ENV['BASIC_AUTH_NAME'].present?
	
	# Store referrer for use after sign-in or sign-up if so directed.
	before_filter :store_referrer, only: :new
	
	# Tell Devise which parameters can be updated in the User model.
	before_filter :configure_permitted_devise_parameters, if: :devise_controller?
	
	# Set security-related HTTP headers for all responses.
	# (For Rails 4, instead use config.action_dispatch.default_headers in config/application.rb.)
	after_filter :set_default_response_headers
	
	# What to do if access is denied or record not found.
	# Prevent fishing for existing, but protected, records by making it look like the page was not found.
	rescue_from CanCan::AccessDenied, with: :not_found
	rescue_from ActiveRecord::RecordNotFound, with: :not_found
	
	# Redirect to an appropriate location with a message.
	# To be used when a resource or page is not found or we have denied access to some part of the site.
	def not_found(exception=nil)
		message = if exception
			"#{exception.class}: #{exception.message}"
		elsif params[:undefined_path]
			"undefined_path=\"#{params[:undefined_path]}\""
		else
			''
		end
		logger.error "Not_found_error: #{message} | request: fullpath=\"#{request.fullpath}\" remote_ip=#{request.remote_ip}"
		if user_signed_in?
			set_flash_message :alert, :page_not_found
			redirect_to root_path
		elsif running_as_private_site?
			set_flash_message :alert, :page_not_found
			redirect_to alpha_sign_up_path
		else
			set_flash_message :alert, :page_not_found_sign_in
			redirect_to new_user_session_path
		end
	end

	# After sign-up or sign-in and if we are a User,
	#   go to the edit_profile page if we are also a provider,
	#   otherwise go to the home page.
	# If we want to go to a different page after sign-up, put that logic in here.
	def after_sign_in_path_for(resource)
		flash[:after_sign_in_path_override] ||
		stored_referrer ||
		stored_location_for(resource) ||
			if resource.is_a?(User)
				resource.is_provider? ? edit_my_profile_path : root_path
			else
				super
			end
	end
	
	# If running as a private site, go to the sign-in page after we sign out (because the home page is blocked).
	# Otherwise, go to the home page.
	def after_sign_out_path_for(resource_or_scope)
		running_as_private_site? ? new_user_session_path : super
	end

	# borrowed from devise
	def set_flash_message(level, tag, options={}) #:nodoc:
		message = translated_message tag, options
		flash[level] = message if message.present?
	end
	
	# Returns the localized message matching the given tag associated with the current controller.
	# If no such tag specified for this controller, then looks for a default for all controllers.
	def translated_message(tag, options={})
		options[:scope] = "controllers"
		options[:default] = Array(options[:default]).unshift(tag.to_sym)
		I18n.t("#{controller_name}.#{tag}", options).presence
	end

	# Translates system error codes into localized error messages
	alias :get_error_message :translated_message
	
	# Work around for the rails3-jquery-autocomplete gem's insistence on showing "no existing match" for no match.
	# This will result in an empty anchor element within the ui-autocomplete list element.
	def get_autocomplete_items(parameters)
		super(parameters).presence || [OpenStruct.new(id: '', parameters[:method].to_s => '')]
	end
	
	private
	
	def require_location_in_profile
		@profile.require_location
	end
	
	def store_referrer
		session[:stored_referrer] ||= request.headers['Referer'] if params[:store_referrer]
	end
	
	def stored_referrer
		session.delete(:stored_referrer)
	end
	
	# Note that the following headers are set by default in production (probably by the force_ssl configuration) and do not need to be set in the set_default_response_headers method.
	#   Strict-Transport-Security:"max-age=31536000"
	#   In the session cookie:
	#     secure:true
	#     httpOnly:true
	
	# Set security-related HTTP headers in the response.
	# See https://www.owasp.org/index.php/List_of_useful_HTTP_headers
	def set_default_response_headers
		response.headers.merge!({
			'X-Frame-Options' => 'DENY',
			'X-XSS-Protection' => '1; mode=block',
			'X-Content-Type-Options' => 'nosniff'
		}) if response
	end
	
	# Call this method for responses that should not be cached, e.g., pages with sensitive information.
	# Be frugal with using this because it can result in a slow experience for the user.
	def set_no_cache_response_headers
		expires_now
	end
	
	def authenticate_user_on_public_site
		authenticate_user! unless running_as_private_site?
	end
	
	def authenticate_user_on_private_site
		authenticate_user! if running_as_private_site?
	end
	
	# If this site is using HTTP basic authentication and this method returns true, skip HTTP basic authentication.
	def skip_http_basic_authentication
		action_name == 'webhook' ||
		['omniauth_callbacks', 'mailchimp_webhook', 'registrations'].include?(controller_name) ||
		(controller_name == 'sessions' && action_name == 'create' && request.format.json?)
	end
	
	# Returns the role value of the current_user that can be used to update attributes.
	def updater_role
		if current_user.try(:admin?)
			:admin
		elsif current_user.try(:profile_editor?)
			:profile_editor
		else
			:default
		end
	end
	
	# Devise's wrapper for strong parameters.
	# Devise's default for sign_in works for us.
	def configure_permitted_devise_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(*User::PASSWORD_ACCESSIBLE_ATTRIBUTES) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(*User::PASSWORD_ACCESSIBLE_ATTRIBUTES) }
	end
end
