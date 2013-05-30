class ApplicationController < ActionController::Base
	protect_from_forgery
	layout 'interior'
	
	http_basic_authenticate_with name: ENV['BASIC_AUTH_NAME'], password: ENV['BASIC_AUTH_PASSWORD'] if ENV['BASIC_AUTH_NAME']
	
	# Store referrer for use after sign-in or sign-up if so directed.
	before_filter :store_referrer, only: :new
	
	# What to do if access is denied or record not found.
	# On production, prevent fishing for existing, but protected, records by making it look like the page was not found.
	rescue_from CanCan::AccessDenied, ActiveRecord::RecordNotFound do |exception|
		raise exception if exception.is_a?(ActiveRecord::RecordNotFound) && ENV["RAILS_ENV"] != 'production'
		# render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
		if user_signed_in?
			set_flash_message :alert, :page_not_found
			redirect_to root_path
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
		stored_referrer ||
		stored_location_for(resource) ||
			if resource.is_a?(User)
				resource.is_provider? ? edit_my_profile_path : root_path
			else
				super
			end
	end

	# borrowed from devise
	def set_flash_message(level, tag, options={}) #:nodoc:
		options[:scope] = "controllers"
		options[:default] = Array(options[:default]).unshift(tag.to_sym)
		message = I18n.t("#{controller_name}.#{tag}", options)
		flash[level] = message if message.present?
	end

	private
	
	def require_location_in_profile
		@profile.require_location
	end
	
	# If current user is an admin and
	#   * the is_published param was used, use it to set the publish state of @profile,
	#   * if any of the admin_notes and lead_generator params are used, set the corresponding profile attribute.
	def process_profile_admin_params
		if current_user.admin?
			@profile.assign_boolean_param_if_used :is_published, params[:is_published]
			@profile.assign_text_param_if_used :admin_notes, params[:admin_notes]
			@profile.assign_text_param_if_used :lead_generator, params[:lead_generator]
		end
	end
	
	def store_referrer
		session[:stored_referrer] ||= request.headers['Referer'] if params[:store_referrer]
	end
	
	def stored_referrer
		session.delete(:stored_referrer)
	end
end
