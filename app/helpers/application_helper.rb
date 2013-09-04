module ApplicationHelper
	
	def company_name
		t 'company.name'
	end
	
	def company_tagline
		t 'company.tagline'
	end
	
	def show_link?(path=nil)
		request.path != path
	end
	
	def sign_in_out_link
		if user_signed_in?
			link_to 'Sign out', destroy_user_session_path, method: :delete
		elsif controller_name != 'sessions'
			link_to 'Sign in', new_user_session_path
		end
	end
	
	def greeting
		"Hello, #{profile_display_name.presence || current_user.username.presence || current_user.email}" if user_signed_in?
	end
	
	def user_home_page
		user_signed_in? && current_user.is_provider? ? my_profile_path : root_path
	end
	
	def sign_up_links
		"Become a #{link_to 'provider', provider_sign_up_path} or a #{link_to 'member', member_sign_up_path}".html_safe unless user_signed_in? || controller_name == 'registrations'
	end
	
	def provider_sign_up_link(body='Provider? Join us')
		link_to body, provider_sign_up_path unless user_signed_in?
	end
	
	def home_link
		link_to "#{company_name}", root_path
	end
	
	def account_settings_link
		path = edit_user_registration_path
		link_to t('views.user.edit.link'), path if user_signed_in?
	end
	
	def view_user_profile_link
		path = view_user_profile_path
		link_to 'View my profile', path if show_link?(path) && can?(:show, User)
	end
	
	def edit_user_profile_link
		path = edit_user_profile_path
		link_to "Edit my profile", path if show_link?(path) && can?(:update, User)
	end
	
	def admin_profile_list_by_id_link
		path = providers_path
		link_to 'List profiles by ID', path if show_link?(path) && can?(:manage, Profile)
	end
	
	def admin_profile_list_link
		path = profiles_path
		link_to 'List profiles', path if show_link?(path) && can?(:manage, Profile)
	end
	
	def admin_change_profile_list_link
		if can? :manage, Profile
			if params[:with_admin_notes].present?
				link_to 'Show all profiles', profiles_path
			else
				link_to 'Show only profiles with admin notes', profiles_path(with_admin_notes: 't')
			end
		end
	end
	
	def admin_create_profile_link
		path = admin_profiles_path
		link_to 'Create a profile', path if show_link?(path) && can?(:create, Profile)
	end
	
	def admin_profiles_link
		path = admin_profiles_path
		link_to 'Profile admin', path if show_link?(path) && can?(:create, Profile)
	end
	
	def admin_link
		path = admin_path
		link_to 'Admin', path if show_link?(path) && can?(:manage, Profile) && can?(:manage, User)
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
		link_to "Terms of use", path if show_link?(path)
	end
	
	def request_expert_link
		path = request_expert_path
		link_to "Request a meeting", path if show_link?(path)
	end
	
	def strip_url(url)
		url.strip.sub(/^https?:\/\//i, '')
	end
	
	def display_url(url, max_length=44)
		truncate strip_url(url), length: max_length
	end
	
	def display_linked_url(url, title=nil)
		if url.present?
			auto_link "http://#{strip_url url}", link: :urls, html: { target: '_blank', title: title } do |body|
				display_url body
			end
		end
	end
	
	# Returns the name value to be used by an input tag that assigns to an array attribute.
	# default_object_name is the name of the attribute's parent object to be used in case the object name can't be derived.
	def array_attribute_tag_name(attr_name, default_object_name, form_builder=nil)
		"#{form_builder.try(:object_name).presence || default_object_name}[#{attr_name}][]"
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
