module ProfilesHelper
	def display_profile_item_names(items, n=nil, separator=nil, &block)
		if items.present?
			n ||= items.length # If n is missing or explicitly passed in as nil, use all items.
			names = items.collect(&:name).sort_by(&:downcase).slice(0, n)
			if block.nil?
				separator ||= ' | '
				names.join(separator) # Join with a separator.
			else
				separator ||= ''
				names.collect(&block).join(separator) # Concatenate result of processing each name.
			end
		end
	end

	def profile_wrap_item_names(items, n=nil, separator=nil)
		display_profile_item_names items, n, separator do |name|
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

	def profile_linked_website(profile=current_user.try(:profile), title=nil, max_length=nil, msg_when_blank=nil)
		if (url = profile.try(:url)).present?
			display_linked_url url, title, max_length
		elsif msg_when_blank
			profile_blank_attribute_message msg_when_blank
		end
	end

	def profile_display_website(profile=current_user.try(:profile), msg_when_blank=nil)
		if (url = profile.try(:url)).present?
			display_url url
		elsif msg_when_blank
			profile_blank_attribute_message msg_when_blank
		end
	end
	
	def profile_linked_email(profile=current_user.try(:profile), title=nil, msg_when_blank=nil)
		if (email = profile.try(:email)).present?
			auto_link email.strip, link: :email_addresses, html: { title: title.try(:html_escape) }
		elsif msg_when_blank
			profile_blank_attribute_message msg_when_blank
		end
	end
	
	def profile_obscured_email(profile=current_user.try(:profile))
		if (email = profile.try(:email)).present?
			email = email.strip
			domain = email.split('@').last
			email_first_char = email[0]
			email_first_char ||= ""
			"#{email_first_char}...@#{domain}"
		else
			''
		end
	end

	def profile_captcha_email(profile=current_user.try(:profile), options={})
		if (email = profile.try(:email)).present?
			hidden_email = truncate profile_obscured_email(profile), length: 24
			mailhide_link = RecaptchaMailhide.url_for(email)
			title = options[:title]
			target = options[:target]
			onclick = options[:onclick] || "window.open(this.href, '#{title}', 'toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0,width=500,height=300,left=200,top=200'); return false;"
			link_to hidden_email, mailhide_link, title: title, target: target, onclick: onclick
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
		link_wrapper link_to(t('views.profile.view.my_profile_link'), path, id: 'view_my_profile_link'), options if can?(:view_my_profile, current_user.profile)
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
		link_to t('views.profile.view.invitation_to_claim_link'), new_invitation_profile_path(profile) if can?(:update, profile)
	end
	
	def profile_invitation_to_claim_info(delivery)
		tracking_category = delivery.tracking_category.presence
		tracking = tracking_category ? "'#{tracking_category}'" : 'subject line'
		t 'views.profile.view.invitation_to_claim_info', invitee: delivery.recipient, time: display_profile_time(delivery.created_at), tracking: tracking
	end

	def profile_invitation_info(profile)
		if can?(:manage, profile) && !profile.claimed?
			if (deliveries = profile.email_deliveries.where(email_type: 'invitation').presence)
				deliveries.map do |delivery|
					profile_invitation_to_claim_info delivery
				end
			elsif profile.contact_blockers.blank?
				[new_invitation_profile_link(profile)]
			end
		end
	end
	
	def profile_stripe_info(profile)
		if (user = profile.user) and can?(:manage, user) and (stripe_info = user.stripe_info)
			t 'views.user.view.stripe_info_created_at', created_at: display_profile_time(stripe_info.created_at)
		end
	end

	def profile_admin_check_box(attribute, profile)
		hidden_field_tag(attribute, '', id: "#{attribute}_not") +
			check_box_tag(attribute, '1', profile.send(attribute), id: attribute)
	end

	def profile_list_view_link(profile, name, options={})
		if can?(:view, profile)
			url = options.delete(:url).presence || profile_path(profile)
			options[:class] = [options[:class].presence, 'emphasized'].compact.join(' ') if name.blank?
			link_to(html_escape(name.presence || 'Click to view/edit'), url, options).html_safe
		else
			name
		end
	end

	def profile_list_name_link(profile, options={})
		profile_list_view_link profile, profile_display_name(profile), options
	end

	def profile_company_otherwise_display_name_link(profile, options={})
		profile_list_view_link profile, profile.company_otherwise_display_name, options
	end
	
	def profile_page_title_prefix(profile)
		[
			profile.presentable_display_name.presence,
			profile.company_name.presence
		].compact.join(' | ') if profile
	end

	def profile_page_title(profile=nil)
		[
			profile_page_title_prefix(profile),
			company_name.presence,
			company_tagline.presence
		].compact.join(' | ')
	end
	
	def profile_page_description(profile)
		[
			profile.company_name.presence,
			profile.presentable_display_name.presence,
			profile.headline.presence
		].compact.join(', ') if profile
	end

	def profile_total_count
		"#{t('views.profile.view.total')}: #{Profile.count}" if can? :manage, Profile
	end

	def profile_owned_count
		"#{t('views.profile.view.owned')}: #{Profile.joins(:user).count}" if can? :manage, Profile
	end

	def profile_not_owned_count
		"#{t('views.profile.view.not_owned')}: #{Profile.where(user_id: nil).count}" if can? :manage, Profile
	end

	def profile_published_count
		"#{t('views.profile.view.published')}: #{Profile.where(is_published: true).count}" if can? :manage, Profile
	end

	def profile_owned_published_count
		"#{t('views.profile.view.owned_published')}: #{Profile.joins(:user).where(is_published: true).count}" if can? :manage, Profile
	end

	def profile_owned_not_published_count
		"#{t('views.profile.view.owned_not_published')}: #{Profile.joins(:user).where(is_published: false).count}" if can? :manage, Profile
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

	def profile_display_subcategories(profile=current_user.try(:profile), n=nil)
		display_profile_item_names profile.try(:subcategories), n
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

	# Subcategories helpers

	def profile_subcategories_id(*ids)
		"profile_subcategories#{ids.map{|id| '_'+id.to_s.to_alphanumeric}.join}"
	end

	def profile_subcategories_tag_name(form_builder=nil)
		profile_attribute_tag_name 'subcategory_ids', form_builder
	end

	def profile_subcategories_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_subcategories_tag_name(form_builder), '', id: profile_subcategories_id('hidden_field')
	end

	def profile_subcategories_check_box_tag(profile, subcategory, category, form_builder=nil)
		element_id = profile_subcategories_id(category.id, subcategory.id)
		css_class = profile_subcategories_id(subcategory.id)
		check_box_tag profile_subcategories_tag_name(form_builder), subcategory.id, profile.subcategories.include?(subcategory), id: element_id, class: css_class, 'data-css-class' => css_class
	end

	def profile_subcategories_check_box_label(subcategory, category)
		label_tag profile_subcategories_id(category.id, subcategory.id), subcategory.name
	end

	# Services helpers

	def profile_new_custom_services(profile)
		(profile.custom_services.presence || []).select(&:new_record?)
	end

	def profile_services_id(*ids)
		"profile_services#{ids.map{|id| '_'+id.to_s.to_alphanumeric}.join}"
	end

	def profile_services_tag_name(form_builder=nil)
		profile_attribute_tag_name 'service_ids', form_builder
	end

	def profile_services_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_services_tag_name(form_builder), '', id: profile_services_id('hidden_field')
	end

	def profile_services_check_box_tag(profile, service, subcategory, form_builder=nil)
		element_id = profile_services_id(subcategory.id, service.id)
		css_class = profile_services_id(service.id)
		check_box_tag profile_services_tag_name(form_builder), service.id, profile.services.include?(service), id: element_id, class: css_class, 'data-css-class' => css_class
	end

	def profile_services_check_box_label(service, subcategory)
		label_tag profile_services_id(subcategory.id, service.id), service.name
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
		autocomplete_form_field profile_custom_specialties_tag_name(form_builder), value, autocomplete_specialty_name_profiles_path, id: profile_custom_specialties_id(suffix), placeholder: I18n.t('views.profile.edit.custom_specialty_placeholder'), 'data-suffix' => suffix
	end
	
	def profile_specialty_names_defaults(profile)
		specialty_names = profile.specialty_names.presence || profile.specialties.map(&:name)
		padding = 5 - specialty_names.size
		specialty_names + [''] * (padding < 1 ? 1 : padding)
	end

	def profile_specialty_names_id(s)
		profile_specialties_id "name_#{s}"
	end

	def profile_specialty_names_tag_name(form_builder=nil)
		profile_attribute_tag_name 'specialty_names', form_builder
	end

	def profile_specialty_names_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_specialty_names_tag_name(form_builder), '', id: profile_specialty_names_id('hidden_field')
	end

	def profile_specialty_names_text_field_tag(profile, value, suffix, form_builder=nil)
		text_field_tag profile_specialty_names_tag_name(form_builder), value, id: profile_specialty_names_id(suffix)
	end

	def profile_specialty_names_autocomplete_field_tag(profile, value, suffix, form_builder=nil)
		autocomplete_form_field profile_specialty_names_tag_name(form_builder), value, autocomplete_specialty_name_profiles_path, id: profile_specialty_names_id(suffix), placeholder: I18n.t('views.profile.edit.specialty_name_placeholder'), 'data-suffix' => suffix
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
		if search.respond_to?(:error) and search.error
			t 'views.search_results.error'
		elsif query.present?
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
	
	def seo_search_query(search, service)
		service.try(:name).presence || search_query_string(search) || ''
	end
	
	def seo_search_description(query, address)
		if address.present?
			"#{query} #{t 'views.search_results.sorted_by_proximity_to', address: address}"
		else
			query
		end
	end

	def search_result_name_specialties(profile)
		specs = html_escape(display_profile_item_names(profile.specialties, 2))
		name_link = profile_company_otherwise_display_name_link(profile)
		s = [name_link.presence, specs.presence].compact.join(' | ')
		name_link.html_safe? ? s.html_safe : s
	end

	def search_result_name_headline(profile)
		headline = html_escape(profile.headline)
		name_link = profile_company_otherwise_display_name_link(profile)
		s = [name_link.presence, headline.presence].compact.join(' | ')
		name_link.html_safe? ? s.html_safe : s
	end

	def search_result_specialties(profile)
		profile_wrap_item_names profile.specialties, 30, ', '
	end

	# Places each specialty in its own span tag.
	# Ensures the resulting HTML is limited by the length option.
	# Note: We prevent the truncation step from escaping all HTML and we tell #sanitize to keep the span tags.
	def search_result_specialties_truncated(profile, options={})
		truncated_list = profile_display_truncated search_result_specialties(profile), length: options[:length], separator: '</span>, <span>', omission: '...</span>', escape: false
		sanitize truncated_list, tags: %w(span)
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

	def provider_rating_stars_css_class(profile)
		rating_score_stars_css_class profile.rating_average_score
	end

	def profile_review_link(profile)
		text_key = profile.has_reviews_by(current_user) ? 'followup_review_provider_link' : 'review_provider_link'
		link_to t(text_key, scope: 'views.profile.view'), new_review_for_profile_url(profile)
	end

	def suggest_provider_link
		link_to t('views.search_results.suggest_provider_link'), '#', class: 'suggest_provider_link'
	end

	def invite_provider_email_subject
		I18n.t "profile_mailer.invite.subject"
	end

	def invite_provider_email_body
		<<-eos 
Hi #{@profile.first_name.presence || 'there'},
<br/>
<br/>
I'm Jim Scott, the founder and CEO of Kinstantly, a new free parenting site that makes it easier for families to find experts like you, learn about your services, and connect in more convenient ways.
<br/>
<br/>
Here's the bonus we promised: To make things as easy as possible, we created a temporary profile for you that highlights the information parents tell us they want. You can take a look and make any changes you'd like by clicking here: #{link_to 'Claim my profile', '<<claim_url>>'}. (Note: To protect your security, you'll first be taken to a sign-in page.)
<br/>
<br/>
In the meantime, here's a bit about me: I'm the former Global VP of Editorial of #{link_to 'BabyCenter', 'http://www.babycenter.com/'}, the largest parenting site in the world, with more than 20 million visitors a month -- and a co-founder of #{link_to 'Caring.com', 'http://www.caring.com/'}, the leading eldercare site in the country. You can learn more about our Kinstantly team and mission by visiting #{link_to 'About Us', about_url}.
<br/>
<br/>
We want to make Kinstantly as perfect for you as we can, so please let me know if you have any questions or suggestions. Just hit reply or shoot me an email to the address below.
<br/>
<br/>
Thanks so much,
<br/>
<br/>
Jim Scott
<br/>
Founder and CEO
<br/>
#{link_to t('company.name'), root_url}
<br/>
#{mail_to 'jscott@kinstantly.com'}
		eos
	end

	def claim_profile_link
		link_to t('views.profile.view.claim_profile_link'), '#', id: 'claim_profile_link', class: 'claim_profile_link'
	end

	def announcement_positions(announcements_total=0, announcement_index=0)
		adding_new_announcement = announcements_total == announcement_index
		min = 1
		max = adding_new_announcement ? announcements_total + 1 : announcements_total
		positions = min..max
		if announcement_index.blank?
			positions.map { |i| [i.ordinalize, i] }
		else
			options_for_select(positions.map { |i| [i.ordinalize, i] }, announcement_index + 1)
		end
	end

	def search_result_positions(first_announcement_position=0, is_first_announcement=true)
		selected_position = first_announcement_position ||= 0
		positions = [['center', 0] , ['upper right', 1]]
		if is_first_announcement == false
			selected_position = (first_announcement_position == 1) ? 0 : 1
		end
		options_for_select(positions, selected_position)
	end

	def get_center_announcement(display_announcement, second_display_announcement, order_changed=false)
		if order_changed && second_display_announcement.present?
			second_display_announcement.search_result_position == 1 ? display_announcement : second_display_announcement
		elsif display_announcement.present? 
			display_announcement.search_result_position == 1 ? second_display_announcement : display_announcement
		end
	end

	def get_upper_right_announcement(display_announcement, second_display_announcement, order_changed=false)
		if order_changed && second_display_announcement.present?
			second_display_announcement.search_result_position == 1 ? second_display_announcement : display_announcement
		elsif display_announcement.present? 
			display_announcement.search_result_position == 1 ? display_announcement : second_display_announcement
		end
	end
	
	def announcement_button(button_text, button_url)
		if button_url.present? && button_text.present?
			auto_link "http://#{strip_url button_url}", link: :urls, html: { target: '_blank', title: button_text.try(:html_escape), class: "button" } do |text|
				button_text.try(:html_escape)
			end
		end
	end
	
	def announcement_icons
		icons = []
		icons << {class: 'announcement', title: 'Good for any general announcement'}
		icons << {class: 'schedule', title:'Best for calendar-based events, such as workshops'}
		icons << {class: 'deal', title: 'Best used to let customers know you accept online payments through Kinstantly or to announce special deals'}
		icons << {class: 'video', title: 'Best to link to a video'}
		icons << {class: 'blog', title: ' Best to link to an article or blog post'}
		icons
	end

	def announcement_icon_class(int_value)
		if int_value.present?
			return announcement_icons[int_value][:class] unless announcement_icons[int_value].blank?
		end
		'announcement'
	end

end
