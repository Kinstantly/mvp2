class Users::ConfirmationsController < Devise::ConfirmationsController
	
	before_filter :set_admin_mode
	
	protected
	
	# The path used after resending confirmation instructions.
	def after_resending_confirmation_instructions_path_for(resource_name)
		if current_user.try :admin?
			set_flash_message :notice, :admin_sent_instructions
			user_path resource
		else
			super
		end
	end

	# The path used after confirmation.
	def after_confirmation_path_for(resource_name, resource)
		if session[:after_confirmation_url].present?
			session.delete :after_confirmation_url
		elsif resource.try(:signed_up_from_blog)
			blog_url
		elsif resource.try(:is_provider?)
			edit_my_profile_path
		else
			super
		end
	end
	
	private
	
	def set_admin_mode
		if current_user.try :admin?
			resource_params.permit :email, :admin_confirmation_sent_by_id
		end
	end
	
end
