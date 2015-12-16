module ApplicationHelper
	
	include SiteConfigurationHelpers
	
	def company_name
		t 'company.name'
	end
	
	def company_tagline
		t 'company.tagline'
	end
	
	def show_link?(path=nil)
		request.path != path
	end
	
	def link_wrapper(link, options={})
		wrapper_options = options[:wrapper] || {}
		wrapper_tag = wrapper_options.delete(:tag)
		if wrapper_tag
			content_tag wrapper_tag, link, wrapper_options
		else
			link
		end
	end
	
	def show_sign_in_link?
		controller_name != 'sessions'
	end

	def show_sign_up_link?
		controller_name != 'registrations'
	end
	
	def sign_in_out_link(options={})
		if user_signed_in?
			link_wrapper link_to(t('views.sign_out.label'), destroy_user_session_path, method: :delete), options
		else
			link_wrapper link_to(t('views.sign_in.label'), new_user_session_path), options
		end
	end
	
	def greeting
		"Hello #{profile_display_name.presence || current_user.username.presence || current_user.email}" if user_signed_in?
	end
	
	def user_home_page
		user_signed_in? && current_user.is_provider? ? my_profile_path : root_path
	end
	
	def sign_up_links
		"Become a #{link_to 'provider', provider_sign_up_path} or a #{link_to 'member', member_sign_up_path}".html_safe unless user_signed_in? || controller_name == 'registrations'
	end

	def user_sign_up_link
		(link_to "Sign up", new_user_registration_path) unless user_signed_in?
	end
	
	def provider_sign_up_link(body='Provider? Join us', options={})
		link_to body, provider_sign_up_path, options unless user_signed_in?
	end
	
	def home_link(options={})
		link_to "#{company_name}", root_path, options
	end
	
	def home_link_with_tagline
		link_to "#{company_name} | #{t 'company.tagline'}", root_path
	end

	def account_settings_link(options={})
		path = edit_user_registration_path
		link_to t('views.user.view.link'), path, options if user_signed_in?
	end
	
	def edit_subscriptions_link
		path = edit_subscriptions_path
		link_to t('views.user.view.edit_subscriptions_link'), path if user_signed_in?
	end
	
	def view_user_profile_link
		path = view_user_profile_path
		link_to t('views.user.view.view_user_profile'), path if show_link?(path) && can?(:show, User)
	end
	
	def edit_user_profile_link
		path = edit_user_profile_path
		link_to t('views.user.view.edit_user_profile'), path if show_link?(path) && can?(:update, User)
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
	
	def admin_provider_suggestion_list_link
		link_to t('views.provider_suggestion.name').pluralize, provider_suggestions_path if can? :manage, ProviderSuggestion
	end
	
	def admin_profile_claim_list_link
		link_to t('views.profile_claim.name').pluralize, profile_claims_path if can? :manage, ProfileClaim
	end
	
	def admin_contact_blocker_links
		if can? :manage, ContactBlocker
			link_to(t('views.contact_blocker.name').pluralize, contact_blockers_path) +
				link_to(t('views.contact_blocker.edit.create'), new_contact_blocker_path)
		end
	end
	
	def admin_category_links
		if can? :manage, Category
			link_to(t('views.category.name').pluralize, categories_path) +
				link_to(t('views.category.edit.create'), new_category_path)
		end
	end
	
	def admin_subcategory_links
		if can? :manage, Subcategory
			link_to(t('views.subcategory.name').pluralize, subcategories_path) +
				link_to(t('views.subcategory.edit.create'), new_subcategory_path)
		end
	end
	
	def admin_service_links
		if can? :manage, Service
			link_to(t('views.service.name').pluralize, services_path) +
				link_to(t('views.service.edit.create'), new_service_path)
		end
	end
	
	def admin_specialty_links
		if can? :manage, Specialty
			link_to(t('views.specialty.name').pluralize, specialties_path) +
				link_to(t('views.specialty.edit.create'), new_specialty_path)
		end
	end
	
	def admin_profiles_not_categorized_links
		if can? :manage, Profile
			link_to(t('views.profile.view.no_categories'), no_categories_profiles_path) +
				link_to(t('views.profile.view.no_subcategories'), no_subcategories_profiles_path) +
				link_to(t('views.profile.view.no_services'), no_services_profiles_path)
		end
	end
	
	def index_link(options={})
		path = root_path
		link_wrapper link_to(t('views.home.view.home'), path), options if show_link?(path)
	end
	
	def about_link(options={})
		path = about_path
		link_wrapper link_to(t('views.home.view.about'), path), options if show_link?(path)
	end
	
	def contact_link(options={})
		path = contact_path
		link_wrapper link_to(t('views.home.view.contact'), path), options if show_link?(path)
	end
	
	def faq_link(options={})
		path = faq_path
		link_wrapper link_to(t('views.home.view.faq'), path), options if show_link?(path)
	end
	
	def terms_link(options={})
		path = terms_path
		link_wrapper link_to(t('views.home.view.terms'), path), options if show_link?(path)
	end

	def privacy_link(options={})
		path = privacy_path
		link_wrapper link_to(t('views.home.view.privacy'), path), options if show_link?(path)
	end

	def find_providers_link(options={})
		link_wrapper link_to(t('views.home.view.providers_html'), root_url(anchor: 'provider-search-browse')), options
	end
	
	def blog_link(options={})
		link_wrapper link_to(t('views.home.view.blog'), blog_url), options
	end

	def newsletter_sign_up_link(options={})
		path = user_signed_in? ? edit_subscriptions_path : newsletter_signup_path
		link_wrapper link_to(t('views.home.view.newsletter_sign_up'), path), options
	end
	
	def become_expert_link
		path = become_expert_path
		link_to "Expert registration", path if show_link?(path)
	end
	
	def request_expert_link
		path = request_expert_path
		link_to "Request a meeting", path if show_link?(path)
	end
	
	def strip_url(url)
		url.strip.sub(/^https?:\/\//i, '') if url
	end
	
	def display_url(url, max_length=nil)
		max_length ||= 44
		truncate strip_url(url), length: max_length
	end
	
	def display_linked_url(url, title=nil, max_length=nil)
		if url.present?
			auto_link "http://#{strip_url url}", link: :urls, html: { target: '_blank', title: title.try(:html_escape) } do |body|
				display_url body, max_length
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
		options[:class] = [options[:class].presence, 'autocomplete-form-field'].compact.join(' ')
		if options[:form_builder]
			options.delete(:form_builder).autocomplete_field attribute, path, options
		else
			autocomplete_field_tag attribute, value, path, options
		end
	end

	# Wrap each name in the specified tag (span by default).
	# Separate each wrapped name with the specified string (nothing by default).
	def display_wrapped_names(names, n=nil, tag=:span, separator='')
		n ||= names.length # If n is missing or explicitly passed in as nil, use all names.
		names.slice(0, n).map do |name|
			content_tag tag, name.html_escape
		end.join(separator).try(:html_safe)
	end
	
	def display_count_for(scope, count)
		count == 0 ? t('none', scope: scope) : t('how_many', scope: scope, count: count)
	end
	
	def select_option_tags(options, selected=nil)
		selected = selected.try(:to_s).try(:html_escape)
		options.inject('') do |option_string, option|
			value, name = option[0].try(:to_s).try(:html_escape), option[1].try(:to_s).try(:html_escape)
			"#{option_string}<option value=\"#{value}\"#{' selected="selected"' if value == selected}>#{name}</option>"
		end.html_safe
	end

	def profile_button_image(profile_path, btn_type)
		case btn_type
		when :reviews
			btn_image = "btn-reviews.gif"
			btn_title = t 'views.user.edit.add_reviews_button_title'
		when :schedule
			btn_image = "btn-schedule.gif"
			btn_title = t 'views.user.edit.add_schedule_button_title'
		when :like
			btn_image = "btn-like.gif"
			btn_title = t 'views.user.edit.add_like_button_title'
		end
		url = "http://#{cloudfront_domain_name}/images/widgets/#{btn_image}"

		if btn_image && btn_title
			content_tag :a, :href => profile_path, :target => '_blank' do
				image_tag url, size: "170x81", alt: btn_title, title: btn_title
			end
		end
	end
	
	def allowed_for_prerelease?
		Rails.env != 'production' || current_user.try(:profile_editor?).present?
	end
end
