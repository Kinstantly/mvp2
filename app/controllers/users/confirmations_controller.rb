class Users::ConfirmationsController < Devise::ConfirmationsController
	# The path used after resending confirmation instructions.
    def after_resending_confirmation_instructions_path_for(resource_name)
    	if current_user.present? && current_user.admin?
    		set_flash_message :notice, :admin_sent_instructions
			users_path
		else
			super
		end
    end
end
