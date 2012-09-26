class ApplicationController < ActionController::Base
	protect_from_forgery

	# If we are a User, go to the edit_profile page after sign-up or sign-in.
	# If we want to go to a different page after sign-up, put that logic in here.
	def after_sign_in_path_for(resource)
		stored_location_for(resource) ||
			if resource.is_a?(User)
				edit_profile_path
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

end
