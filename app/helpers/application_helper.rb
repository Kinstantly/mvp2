module ApplicationHelper
	
	def company_name
		'Zatch.me'
	end
	
	def show_link?(path=nil)
		request.path != path
	end
	
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
		path = root_path
		link_to "#{company_name}", path if show_link?(path)
	end
	
	def view_user_profile_link
		path = view_user_profile_path
		link_to 'View my profile', path if show_link?(path) && can?(:show, User)
	end
	
	def edit_user_profile_link
		path = edit_user_profile_path
		link_to "Edit profile", path if show_link?(path) && can?(:update, User)
	end
	
	def admin_profile_list_link
		path = profiles_path
		link_to 'Profile admin', path if show_link?(path) && can?(:manage, Profile)
	end
	
	def admin_create_profile_link
		path = new_profile_path
		link_to 'Create profile', path if show_link?(path) && can?(:create, Profile)
	end
	
	def about_link
		path = about_path
		link_to "About us", path if show_link?(path)
	end
	
	def become_expert_link
		path = become_expert_path
		link_to "Expert registration", path if show_link?(path)
	end
	
	def contact_link
		path = contact_path
		link_to "Contact us", path if show_link?(path)
	end
	
	def faq_link
		path = faq_path
		link_to "FAQ", path if show_link?(path)
	end
	
	def policies_link
		path = policies_path
		link_to "Policies", path if show_link?(path)
	end
	
	def request_expert_link
		path = request_expert_path
		link_to "Request a meeting", path if show_link?(path)
	end
end
