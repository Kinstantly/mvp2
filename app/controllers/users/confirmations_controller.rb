class Users::ConfirmationsController < Devise::ConfirmationsController
	
	before_filter :set_admin_mode
	
	protected
	
	# The path used after resending confirmation instructions.
	def after_resending_confirmation_instructions_path_for(resource_name)
		if current_user.present? && current_user.admin?
			set_flash_message :notice, :admin_sent_instructions
			edit_user_path resource
		else
			super
		end
	end

	# The path used after confirmation.
	def after_confirmation_path_for(resource_name, resource)
		resource.try(:is_provider?) ? edit_my_profile_path : super
	end
	
	private
	
	def set_admin_mode
		resource_params[:admin_mode] = current_user.try :admin? if running_as_private_site?
	end
	
end
