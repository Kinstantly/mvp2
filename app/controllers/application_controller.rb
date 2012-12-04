class ApplicationController < ActionController::Base
	protect_from_forgery
	
	rescue_from CanCan::AccessDenied do |exception|
		# render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
		set_flash_message :alert, :access_denied
		redirect_to root_url
	end

	# If we are a User, go to the edit_profile page after sign-up or sign-in.
	# If we want to go to a different page after sign-up, put that logic in here.
	def after_sign_in_path_for(resource)
		stored_location_for(resource) ||
			if resource.is_a?(User)
				edit_user_profile_path
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
	
	# If current user is an admin and the is_published param was used,
	# use it to set the publish state of @profile.
	def process_profile_publish_param
		if current_user.admin?
			is_published = params[:is_published]
			@profile.is_published = is_published.present? if is_published
		end
	end
end
