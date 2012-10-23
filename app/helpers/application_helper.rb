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
			link_to "Become a #{company_name} expert", new_user_registration_path
		end
	end
	
	def home_link
		link_to "#{company_name}", root_path unless controller_name == 'home' && action_name == 'index'
	end
	
	def view_profile_link
		link_to 'View my profile', view_user_profile_path if user_signed_in? && 
			(controller_name != 'users' || (controller_name == 'users' && action_name == 'index'))
	end
	
	def admin_profile_list_link
		link_to 'Profile admin', profiles_path if user_signed_in? && can?(:read, Profile) &&
			!(controller_name == 'profiles' && action_name == 'index')
	end
	
	def company_name
		'Zatch.me'
	end
	
	def about_link
		link_to "About us", about_path unless controller_name == 'home' && action_name == 'about'
	end
	
	def become_expert_link
		link_to "Expert registration", become_expert_path unless controller_name == 'home' && action_name == 'become_expert'
	end
	
	def contact_link
		link_to "Contact us", contact_path unless controller_name == 'home' && action_name == 'contact'
	end
	
	def faq_link
		link_to "FAQ", faq_path unless controller_name == 'home' && action_name == 'faq'
	end
	
	def policies_link
		link_to "Policies", policies_path unless controller_name == 'home' && action_name == 'policies'
	end
	
	def request_expert_link
		link_to "Request a meeting", request_expert_path unless controller_name == 'home' && action_name == 'request_expert'
	end
end
