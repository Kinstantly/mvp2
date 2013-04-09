module ApplicationHelper
	
	def company_name
		'Get Answers 5555'
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
		"Hello, #{profile_display_name.presence || current_user.username.presence || current_user.email}" if user_signed_in?
	end
	
	def sign_up_links
		"Become a #{link_to 'provider', provider_sign_up_path} or a #{link_to 'member', member_sign_up_path}".html_safe unless user_signed_in? || controller_name == 'registrations'
	end
	
	def provider_sign_up_link
		link_to 'Become a provider', provider_sign_up_path unless user_signed_in? || controller_name == 'registrations'
	end
	
	def home_link
		path = root_path
		link_to "#{company_name}", path if show_link?(path)
	end
	
	def account_settings_link
		path = edit_user_registration_path
		link_to 'Account settings', path if user_signed_in? && show_link?(path)
	end
	
	def view_user_profile_link
		path = view_user_profile_path
		link_to 'View my profile', path if show_link?(path) && can?(:show, User)
	end
	
	def edit_user_profile_link
		path = edit_user_profile_path
		link_to "Edit my profile", path if show_link?(path) && can?(:update, User)
	end
	
	def admin_profile_list_link
		path = profiles_path
		link_to 'Profile admin', path if show_link?(path) && can?(:manage, Profile)
	end
	
	def admin_change_profile_list_link
		if current_user.try(:admin?)
			if params[:with_admin_notes].present?
				link_to 'Show all profiles', profiles_path
			else
				link_to 'Show only profiles with admin notes', profiles_path(with_admin_notes: 't')
			end
		end
	end
	
	def admin_create_profile_link
		path = new_profile_path
		link_to 'Create a profile', path if show_link?(path) && can?(:create, Profile)
	end
	
	def admin_user_list_link
		path = users_path
		link_to 'User admin', path if show_link?(path) && can?(:manage, User)
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
	
	def terms_link
		path = terms_path
		link_to "Terms of Use", path if show_link?(path)
	end
	
	def request_expert_link
		path = request_expert_path
		link_to "Request a meeting", path if show_link?(path)
	end
	
	# Use this helper to work around a bug that causes an unchecked undefined value when using jQuery 1.9.
	# http://github.com/crowdint/rails3-jquery-autocomplete/issues/210
	def autocomplete_form_field(attribute, value, path, options={})
		options[:id_element] ||= ''
		options[:update_elements] ||= {}
		if options[:form_builder]
			options.delete(:form_builder).autocomplete_field attribute, path, options
		else
			autocomplete_field_tag attribute, value, path, options
		end
	end
end
