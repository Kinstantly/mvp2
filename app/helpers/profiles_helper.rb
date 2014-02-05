module ProfilesHelper
	def display_profile_item_names(items, n=nil, &block)
		if items.present?
			n ||= items.length # If n is missing or explicitly passed in as nil, use all items.
			names = items.collect(&:name).sort_by(&:downcase).slice(0, n)
			if block.nil?
				names.join(' | ') # Join with a separator.
			else
				names.collect(&block).join('') # Concatenate result of processing each name.
			end
		end
	end

	def profile_wrap_item_names(items, n=nil)
		display_profile_item_names items, n do |name|
			content_tag :span, name.html_escape
		end.try(:html_safe)
	end

	def display_profile_time(time_with_zone)
		time_with_zone.localtime.strftime('%a, %b %d, %Y %l:%M %p %Z')
	end
	
	def display_profile_date(time_with_zone)
		time_with_zone.localtime.strftime('%b %-d, %Y')
	end

	def default_profile_country
		DEFAULT_COUNTRY_CODE
	end

	def profile_blank_attribute_message(msg)
		content_tag :span, msg, class: 'blank_attr'
	end

	def profile_country(profile=current_user.try(:profile))
		profile.try(:locations).try(:first).try(:country).presence || default_profile_country
	end

	def profile_display_name(profile=current_user.try(:profile))
		profile.try(:display_name).presence || ''
	end

	def profile_age_ranges(profile=current_user.try(:profile))
		(profile.try(:age_ranges).presence || []).sort_by(&:sort_index).inject([]) { |display_ranges, age_range|
			if (start = age_range.start).present? && (last = display_ranges.last).present? && start == last[:end]
				last[:end] = age_range.end
				last[:name] = "#{last[:start]}-#{last[:end]}"
				display_ranges
			else
				display_ranges << {name: age_range.name, start: age_range.start, end: age_range.end}
			end
		}.map{ |range| range[:name] }.join(', ')
	end

	def profile_create_links(text)
		auto_link text, link: :urls, html: { target: '_blank', class: 'dont_popover' } do |body|
			display_url body, 40
		end
	end

	def profile_linked_photo_source(profile=current_user.try(:profile), title=nil)
		display_linked_url profile.try(:photo_source_url), title
	end

	def profile_linked_website(profile=current_user.try(:profile), title=nil)
		display_linked_url profile.try(:url), title
	end

	def profile_display_website(profile=current_user.try(:profile), msg_when_blank=nil)
		if (url = profile.try(:url)).present?
			display_url url
		elsif msg_when_blank
			profile_blank_attribute_message msg_when_blank
		end
	end
	
	def profile_linked_email(profile=current_user.try(:profile), title=nil)
		if (email = profile.try(:email)).present?
			auto_link email.strip, link: :email_addresses, html: { title: title }
		end
	end
	
	def profile_obscured_email(profile=current_user.try(:profile))
		if (email = profile.try(:email)).present?
			email = email.strip
			domain = email.split('@').last
			email_first_char = email[0]
			email_first_char ||= ""
			"#{email_first_char}..@#{domain}"
		else
			''
		end
	end

	def profile_captcha_email(profile=current_user.try(:profile), title=nil)
		if (email = profile.try(:email)).present?
			hidden_email = profile_obscured_email profile
			mailhide_link = RecaptchaMailhide::URL.url_for(email)
			js_click_event = "window.open(this.href, '#{title}', 'toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0,width=500,height=300,left=200,top=200'); return false;"
			link_to hidden_email, mailhide_link, { title: title, onclick: js_click_event }
		end
	end

	def profile_display_email(profile=current_user.try(:profile), msg_when_blank=nil)
		if (email = profile.try(:email)).present?
			email.strip
		elsif msg_when_blank
			profile_blank_attribute_message msg_when_blank
		end
	end

	def location_linked_phone(location=current_user.try(:profile).try(:locations).try(:first), title=nil)
		if (phone = location.try(:phone)).present? && (parsed_phone = Phonie::Phone.parse(phone))
			link_to location.display_phone, parsed_phone.format('tel:+%c%a%f%l'), title: title
		end
	end

	def profile_attribute_tag_name(attr_name, form_builder=nil)
		array_attribute_tag_name attr_name, 'profile', form_builder
	end

	def profile_link(profile)
		link_to "View profile", profile_path(profile) if can?(:show, profile)
	end

	def edit_profile_link(profile)
		link_to "Edit profile", edit_profile_path(profile) if can?(:update, profile)
	end

	def view_my_profile_link(options={})
		path = my_profile_path
		link_wrapper link_to(t('views.profile.view.my_profile_link'), path, id: 'view_my_profile_link'), options if can?(:view_my_profile, current_user.profile) && show_link?(path)
	end

	def edit_my_profile_link(options={})
		link_wrapper link_to(t('views.profile.view.edit_my_profile_link'), edit_my_profile_path, id: 'edit_my_profile_link'), options if can?(:edit_my_profile, current_user.profile)
	end

	# temporary; until the legacy code is fully merged into the new design; only to be used by profile editors.
	def full_profile_link(profile)
		link_to "View full profile", show_plain_profile_path(profile) if can?(:manage, profile)
	end
	def edit_full_profile_link(profile)
		link_to "Edit full profile", edit_plain_profile_path(profile) if can?(:manage, profile)
	end

	def new_invitation_profile_link(profile)
		link_to t('views.profile.view.invitation_to_claim_link'), new_invitation_profile_path(profile), id: 'new_invitation_profile' if can?(:update, profile)
	end

	def profile_invitation_info(profile)
		if can?(:manage, profile) && !profile.claimed?
			if profile.invitation_sent_at
				t 'views.profile.view.invitation_to_claim_info', invitee: profile.invitation_email, time: display_profile_time(profile.invitation_sent_at)
			else
				new_invitation_profile_link profile
			end
		end
	end

	def profile_publish_check_box(tag_name, profile)
		hidden_field_tag(tag_name, '', id: 'is_published_not') +
			check_box_tag(tag_name, '1', profile.is_published, id: 'is_published')
	end

	def profile_list_view_link(profile, name, html_options={})
		if can?(:view, profile)
			html_options[:class] = [html_options[:class].presence, 'emphasized'].compact.join(' ') if name.blank?
			link_to(html_escape(name.presence || 'Click to view'), profile_path(profile), html_options).html_safe
		else
			name
		end
	end

	def profile_list_name_link(profile, html_options={})
		profile_list_view_link profile, profile_display_name(profile), html_options
	end

	def profile_list_name_or_company_link(profile, html_options={})
		profile_list_view_link profile, profile.display_name_or_company, html_options
	end

	def profile_page_title(profile=nil)
		[company_name.presence, profile.try(:display_name_or_company).presence].compact.join(' - ')
	end

	def profile_total_count
		"Total: #{Profile.count}"
	end

	def profile_claimed_count
		"Claimed: #{Profile.where('user_id is not null').count}"
	end

	def profile_unclaimed_count
		"Unclaimed: #{Profile.where(user_id: nil).count}"
	end

	def profile_published_count
		"Published: #{Profile.where(is_published: true).count}"
	end

	def serialize_profile_text(text)
		text.strip.gsub(/\s*\n+\s*/, ', ') if text
	end

	def preserve_profile_text(text)
		preserve (text.html_safe? ? text : text.html_escape) if text
	end

	# The order of processing matters.
	def profile_display_text(text, options={})
		text = serialize_profile_text text                   if options[:serialize]
		text = profile_create_links text                     if options[:links]
		text = preserve_profile_text text                    if options[:preserve]
		text = truncate text, { length: options[:truncate] } if options[:truncate]
		text
	end

	def profile_display_truncated(text, options={})
		create_links = options.delete :links
		text = truncate text, {length: 80, separator: ' ', omission: '...'}.merge(options)
		text = profile_create_links text if create_links
		text
	end

	def profile_display_categories_services_specialties(profile, n=nil)
		[profile_display_categories(profile, n).presence,
			profile_display_services(profile, n).presence,
			profile_display_specialties(profile, n).presence].compact.join(' | ')
	end

	def profile_display_services_specialties(profile, n=nil)
		[profile_display_services(profile, n).presence,
			profile_display_specialties(profile, n).presence].compact.join(' | ')
	end
	
	def profile_display_checked_attributes(profile, *attributes)
		display_wrapped_names profile.human_attribute_names_if_present(*attributes), nil, :span, '<br>'
	end

	# Categories helpers

	def profile_category_choices(profile)
		(Category.predefined + profile.categories.reject(&:new_record?)).uniq.sort_by &:lower_case_name
	end

	def profile_new_custom_categories(profile)
		(profile.custom_categories.presence || []).select(&:new_record?)
	end

	def profile_categories_id(s)
		"profile_categories_#{s.to_s.to_alphanumeric}"
	end

	def profile_categories_tag_name(form_builder=nil)
		profile_attribute_tag_name 'category_ids', form_builder
	end

	def profile_categories_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_categories_tag_name(form_builder), '', id: profile_categories_id('hidden_field')
	end

	def profile_categories_check_box_tag(profile, category, form_builder=nil)
		check_box_tag profile_categories_tag_name(form_builder), category.id, profile.categories.include?(category), id: profile_categories_id(category.id)
	end

	def profile_categories_check_box_label(category)
		label_tag profile_categories_id(category.id), category.name
	end

	def profile_display_categories(profile=current_user.try(:profile), n=nil)
		display_profile_item_names profile.try(:categories), n
	end

	def profile_custom_categories_id(s)
		profile_categories_id "custom_#{s}"
	end

	def profile_custom_categories_tag_name(form_builder=nil)
		profile_attribute_tag_name 'custom_category_names', form_builder
	end

	def profile_custom_categories_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_custom_categories_tag_name(form_builder), '', id: profile_custom_categories_id('hidden_field')
	end

	def profile_custom_categories_text_field_tag(profile, value, suffix, form_builder=nil)
		text_field_tag profile_custom_categories_tag_name(form_builder), value, id: profile_custom_categories_id(suffix)
	end

	# Services helpers

	def profile_new_custom_services(profile)
		(profile.custom_services.presence || []).select(&:new_record?)
	end

	def profile_services_id(s)
		"profile_services_#{s.to_s.to_alphanumeric}"
	end

	def profile_services_tag_name(form_builder=nil)
		profile_attribute_tag_name 'service_ids', form_builder
	end

	def profile_services_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_services_tag_name(form_builder), '', id: profile_services_id('hidden_field')
	end

	def profile_services_check_box(profile, id, name, checked, wrapper_class, form_builder=nil)
		tag_id = profile_services_id(id)
		content_tag :div, class: wrapper_class do
			check_box_tag(profile_services_tag_name(form_builder), id, checked, id: tag_id) + label_tag(tag_id, name)
		end
	end

	def profile_services_check_box_cache(profile, wrapper_class, form_builder=nil)
		cache = {}
		profile.services.uniq.each do |svc|
			cache[svc.id] = profile_services_check_box profile, svc.id, svc.name, true, wrapper_class, form_builder
		end
		cache
	end

	def profile_display_services(profile=current_user.try(:profile), n=nil)
		display_profile_item_names profile.try(:services), n
	end

	def profile_custom_services_id(s)
		profile_services_id "custom_#{s}"
	end

	def profile_custom_services_tag_name(form_builder=nil)
		profile_attribute_tag_name 'custom_service_names', form_builder
	end

	def profile_custom_services_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_custom_services_tag_name(form_builder), '', id: profile_custom_services_id('hidden_field')
	end

	def profile_custom_services_text_field_tag(profile, value, suffix, form_builder=nil)
		text_field_tag profile_custom_services_tag_name(form_builder), value, id: profile_custom_services_id(suffix)
	end

	def profile_custom_services_autocomplete_field_tag(profile, value, suffix, form_builder=nil)
		autocomplete_form_field profile_custom_services_tag_name(form_builder), value, autocomplete_service_name_profiles_path, id: profile_custom_services_id(suffix), placeholder: I18n.t('views.profile.edit.custom_service_placeholder')
	end

	# Specialties helpers

	def profile_new_custom_specialties(profile)
		(profile.custom_specialties.presence || []).select(&:new_record?)
	end

	def profile_specialties_id(s)
		"profile_specialties_#{s.to_s.to_alphanumeric}"
	end

	def profile_specialties_tag_name(form_builder=nil)
		profile_attribute_tag_name 'specialty_ids', form_builder
	end

	def profile_specialties_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_specialties_tag_name(form_builder), '', id: profile_specialties_id('hidden_field')
	end

	def profile_specialties_check_box(profile, id, name, checked, wrapper_class, form_builder=nil)
		tag_id = profile_specialties_id(id)
		content_tag :div, class: wrapper_class do
			check_box_tag(profile_specialties_tag_name(form_builder), id, checked, id: tag_id) + label_tag(tag_id, name)
		end
	end

	def profile_specialties_check_box_cache(profile, wrapper_class, form_builder=nil)
		cache = {}
		profile.specialties.uniq.each do |spec|
			cache[spec.id] = profile_specialties_check_box profile, spec.id, spec.name, true, wrapper_class, form_builder
		end
		cache
	end

	def profile_display_specialties(profile=current_user.try(:profile), n=nil)
		display_profile_item_names profile.try(:specialties), n
	end

	def profile_custom_specialties_id(s)
		profile_specialties_id "custom_#{s}"
	end

	def profile_custom_specialties_tag_name(form_builder=nil)
		profile_attribute_tag_name 'custom_specialty_names', form_builder
	end

	def profile_custom_specialties_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_custom_specialties_tag_name(form_builder), '', id: profile_custom_specialties_id('hidden_field')
	end

	def profile_custom_specialties_text_field_tag(profile, value, suffix, form_builder=nil)
		text_field_tag profile_custom_specialties_tag_name(form_builder), value, id: profile_custom_specialties_id(suffix)
	end

	def profile_custom_specialties_autocomplete_field_tag(profile, value, suffix, form_builder=nil)
		autocomplete_form_field profile_custom_specialties_tag_name(form_builder), value, autocomplete_specialty_name_profiles_path, id: profile_custom_specialties_id(suffix), placeholder: I18n.t('views.profile.edit.custom_specialty_placeholder')
	end

	# Age range helpers

	def profile_age_ranges_id(s)
		"profile_age_ranges_#{s.to_alphanumeric}"
	end

	def profile_age_ranges_tag_name(form_builder=nil)
		profile_attribute_tag_name 'age_range_ids', form_builder
	end

	def profile_age_ranges_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_age_ranges_tag_name(form_builder), '', id: profile_age_ranges_id('hidden_field')
	end

	def profile_age_ranges_check_box_tag(profile, age_range, form_builder=nil)
		check_box_tag profile_age_ranges_tag_name(form_builder), age_range.id, profile.age_ranges.include?(age_range), id: profile_age_ranges_id(age_range.name)
	end

	def profile_age_ranges_check_box_label(age_range)
		label_tag profile_age_ranges_id(age_range.name), age_range.name
	end

	# Consultations and visits

	def profile_consult_by_email_element(profile=current_user.try(:profile))
		if profile.try(:consult_by_email).present?
			title = Profile.human_attribute_name :consult_by_email
			profile_linked_email(profile, title).presence || content_tag(:span, title, title: title)
		end
	end

	def profile_consult_by_phone_element(profile=current_user.try(:profile))
		if profile.try(:consult_by_phone).present?
			title = Profile.human_attribute_name :consult_by_phone
			location_linked_phone(profile.try(:locations).try(:first), title).presence || content_tag(:span, title, title: title)
		end
	end

	def profile_contact_icon_element(attribute, profile=current_user.try(:profile))
		if profile.try(attribute.to_sym).present?
			title = Profile.human_attribute_name attribute
			content_tag :span, title, title: title
		end
	end

	def profile_has_consultation_mode(profile)
		profile.consult_by_email || profile.consult_by_phone || profile.consult_by_video ||
			profile.consult_in_person || profile.consult_in_group || profile.visit_home || profile.visit_school ||
			profile.consult_at_hospital || profile.consult_at_camp || profile.consult_at_other
	end

	def profile_display_consultation_modes(profile)
		return '' unless profile
		[:visit_home, :consult_by_video, :consult_by_phone, :consult_by_email, :visit_school].map do |attribute|
			Profile.human_attribute_name attribute if profile.send attribute
		end.compact.join(' | ')
	end

	# Accepting new clients
	def profile_display_accepting_new_clients(profile)
		profile.accepting_new_clients ? t('views.profile.view.accepting_new_clients') : t('views.profile.view.not_accepting_new_clients')
	end

	def profile_display_consult_remotely(profile)
		profile.consult_remotely ? Profile.human_attribute_name(:consult_remotely) : t('views.profile.view.does_not_consult_remotely')
	end

	# Search

	def search_query_string(search)
		q = search.try(:query).try(:to_params).try(:'[]', :q)
		q == '*:*' ? '' : q
	end

	def search_area_tag_options(selected=nil)
		(anywhere_tag = SearchAreaTag.new).name = 'Anywhere'
		options_from_collection_for_select(SearchAreaTag.all_ordered.unshift(anywhere_tag), :id, :name, selected)
	end

	def in_search_area(id)
		id.present? && (name = SearchAreaTag.find_by_id(id).try(:name)) ? t('views.search_results.in_search_area', name: name) : nil
	end

	def search_results_title(search, options={})
		total = search.total
		query = if options[:service]
			options[:service].name
		else
			search_query_string search
		end
		search_area = in_search_area options[:search_area_tag_id]
		sorted_by_proximity = options[:address].present? && total > 1 ? t('views.search_results.sorted_by_proximity_to', address: options[:address]) : nil
		addendum = [search_area, sorted_by_proximity].compact.join(' ')
		if query.present?
			t_scope = 'views.search_results.found_for'
			"#{total > 0 ? t('how_many', scope: t_scope, count: total, query: query) : t('none', scope: t_scope, query: query)} #{addendum}"
		else
			t_scope = 'views.search_results.found'
			"#{total > 0 ? t('how_many', scope: t_scope, count: total) : t('none', scope: t_scope)} #{addendum}"
		end
	end

	def default_search_query(query, service)
		service.try(:name).presence || query
	end

	def search_result_name_specialties(profile)
		specs = html_escape(display_profile_item_names(profile.specialties, 2))
		name_link = profile_list_name_or_company_link(profile)
		s = [name_link.presence, specs.presence].compact.join(' | ')
		name_link.html_safe? ? s.html_safe : s
	end

	def search_result_name_headline(profile)
		headline = html_escape(profile.headline)
		name_link = profile_list_name_or_company_link(profile)
		s = [name_link.presence, headline.presence].compact.join(' | ')
		name_link.html_safe? ? s.html_safe : s
	end

	def search_result_specialties(profile)
		profile_wrap_item_names profile.specialties
	end

	def search_result_specialties_truncated(profile, options={})
		sanitize profile_display_truncated search_result_specialties(profile), length: options[:length], separator: '</span><span>', omission: '...</span>'
	end

	# Show the first location associated with the profile.
	# Show a count if there is more than one location.
	def search_result_location(profile)
		s = profile.first_location.try(:display_city_region)
		n = profile.locations.size # call 'size' to take advantage of counter caching.
		s += " #{t 'views.location.view.total.how_many', count: n}" if n > 1
		s
	end

	def search_result_consultations(profile)
		icons = []
		icons << 'email' if profile.consult_by_email
		icons << 'phone' if profile.consult_by_phone
		icons << 'video' if profile.consult_by_video
		icons << 'office' if profile.consult_in_person
		icons << 'group' if profile.consult_in_group
		icons << 'home' if profile.visit_home
		icons << 'school' if profile.visit_school
		icons << 'hospital' if profile.consult_at_hospital
		icons << 'camp' if profile.consult_at_camp
		icons << 'other' if profile.consult_at_other
		icons.join(' | ')
	end

	# Provider rating and review
	def provider_rating_title(rating)
		I18n.t "rating.score_#{rating.floor}"
	end

	def provider_rating_average_score(profile)
		profile.rating_average_score.try(:round, 1) || t('rating.no_score')
	end

	def profile_review_link(profile)
		provider_name = profile.display_name_or_company
		#uri = 'https://docs.google.com/forms/d/1dD9rrSGzhrCRyozj1qJwUrrBbANinm4BLJfrz7QfIQw/viewform?entry.1072639882=' +
		#	CGI.escape(provider_name.presence || '')
		#if user_signed_in?
		#	uri += '&entry.288618633=' + CGI.escape(current_user.email.presence || '')
		#	uri += '&entry.1551105972=' + CGI.escape(current_user.username.presence || '')
		#end
		#link_to t('views.profile.view.review_provider_link', name: provider_name), uri.html_safe, target: '_blank'
		link_to t('views.profile.view.review_provider_link', name: provider_name), new_review_for_profile_url(profile)
	end

	def suggest_provider_link
		uri = 'https://docs.google.com/forms/d/1W690ALolhjBoN7WbWt3-87mc0d-DTFvlTQR6MrbxONw/viewform'
		if user_signed_in?
			uri += '?entry.927816333=' + CGI.escape(current_user.email.presence || '')
		end
		link_to t('views.search_results.suggest_provider_link'), uri.html_safe, target: '_blank'
	end
end
