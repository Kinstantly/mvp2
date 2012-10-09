module ApplicationHelper
	def sign_in_out_link
		if user_signed_in?
			link_to 'Logout', destroy_user_session_path, method: :delete
		elsif controller_name != 'sessions'
			link_to 'Login', new_user_session_path
		end
	end
	
	def greeting
		if user_signed_in?
			"Hello, #{profile_display_name.presence || current_user.email}"
		elsif controller_name != 'registrations'
			link_to 'Join us!', new_user_registration_path
		end
	end
	
	def home_link
		link_to 'Get Answers', root_path unless controller_name == 'home'
	end
	
	def view_profile_link
		link_to 'View my profile', view_profile_path if user_signed_in? && 
			(controller_name != 'users' || (controller_name == 'users' && action_name == 'index'))
	end
	
	def company_name
		'Zatch'
	end
end
