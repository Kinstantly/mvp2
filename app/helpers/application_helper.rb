module ApplicationHelper
	def sign_in_out_link
		if user_signed_in?
			link_to 'Logout', destroy_user_session_path, method: :delete, class: 'sign_out'
		else
			link_to 'Login', new_user_session_path, class: 'sign_in'
		end
	end
	
	def greeting
		if user_signed_in?
			"Hello, #{current_user.email}"
		else
			link_to 'Join us!', new_user_registration_path, class: 'sign_up'
		end
	end
end
