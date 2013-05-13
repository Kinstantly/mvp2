module ProfilesHelper
	def display_profile_item_names(items, n=nil)
		n ||= items.try(:length)
		items.collect(&:name).sort{|a, b| a.casecmp b}.slice(0, n).join(' | ') if items.present?
	end
	
	def display_profile_time(time_with_zone)
		time_with_zone.localtime.strftime('%a, %b %d, %Y %l:%M %p %Z')
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
	
	def profile_linked_website(profile=current_user.try(:profile), title=nil)
		if (url = profile.try(:url)).present?
			auto_link "http://#{strip_url url}", link: :urls, html: { target: '_blank', title: title } do |body|
				display_url body
			end
		end
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
		"#{form_builder.try(:object_name).presence || 'profile'}[#{attr_name}][]"
	end
	
	def profile_link(profile)
		link_to "View profile", profile_path(profile) if can?(:show, profile)
	end
	
	def edit_profile_link(profile)
		link_to "Edit profile", edit_profile_path(profile) if can?(:update, profile)
	end
	
	def view_my_profile_link(profile)
		link_to "View my profile", my_profile_path if can?(:view_my_profile, profile)
	end
	
	def edit_my_profile_link(profile)
		link_to "Edit my profile", edit_my_profile_path if can?(:edit_my_profile, profile)
	end
	
	# temporary; until the legacy code is fully merged into the new design; only to be used by profile editors.
	def full_profile_link(profile)
		link_to "View full profile", show_plain_profile_path(profile) if can?(:manage, profile)
	end
	def edit_full_profile_link(profile)
		link_to "Edit full profile", edit_plain_profile_path(profile) if can?(:manage, profile)
	end
	
	def new_invitation_profile_link(profile)
		link_to "Send invitation to claim", new_invitation_profile_path(profile), id: 'new_invitation_profile' if can?(:update, profile)
	end
	
	def profile_invitation_info(profile)
		if can?(:manage, profile) && !profile.claimed?
			if profile.invitation_sent_at
				"Invitation to claim has been sent to #{profile.invitation_email} at #{display_profile_time profile.invitation_sent_at}"
			else
				new_invitation_profile_link profile
			end
		end
	end
	
	def profile_publish_check_box(tag_name, profile)
		hidden_field_tag(tag_name, '', id: 'is_published_not') +
			check_box_tag(tag_name, '1', profile.is_published, id: 'is_published')
	end
	
	def profile_list_view_link(profile, name)
		if can?(:view, profile)
			html_options = name.blank? ? {class: 'emphasized'} : {}
			link_to(html_escape(name.presence || 'Click to view'), profile_path(profile), html_options).html_safe
		else
			name
		end
	end
	
	def profile_list_name_link(profile)
		profile_list_view_link profile, profile_display_name(profile)
	end
	
	def profile_list_name_or_company_link(profile)
		profile_list_view_link(profile, (profile_display_name(profile).presence || profile.company_name))
	end
	
	def profile_parent_child_info(parents, child_association, map={}, names={})
		parents.each { |parent|
			children = parent.send child_association
			map[parent.id] ||= children.map &:id
			children.each { |child| names[child.id] ||= child.name.html_escape }
		}
		[map, names]
	end
	
	def profile_categories_services_info(profile)
		predefined_info = Category.predefined_parent_child_info do
			profile_parent_child_info Category.predefined, :services
		end
		profile_parent_child_info profile.categories, :services, *predefined_info
	end

	def profile_services_specialties_info(profile)
		predefined_info = Service.predefined_parent_child_info do
			profile_parent_child_info Service.predefined, :specialties
		end
		profile_parent_child_info profile.services, :specialties, *predefined_info
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
	
	def serialize_profile_text(text)
		text.strip.gsub(/\s*\n+\s*/, ', ') if text
	end
	
	def preserve_profile_text(text)
		preserve text.strip if text
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

	# Categories helpers
	
	def profile_category_choices(profile)
		(Category.predefined + profile.categories.reject(&:new_record?)).uniq.sort { |a, b| a.name.casecmp b.name }
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
	
	def profile_service_choices(profile)
		(Service.predefined + profile.services.reject(&:new_record?)).uniq.sort { |a, b| a.name.casecmp b.name }
	end
	
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
			profile.consult_at_hospital || profile.consult_at_camp
	end
	
	def profile_display_consultation_modes(profile)
		return '' unless profile
		modes = []
		modes.push 'email' if profile.consult_by_email
		modes.push 'phone' if profile.consult_by_phone
		modes.push 'video' if profile.consult_by_video
		modes.push 'office' if profile.consult_in_person
		modes.push 'group' if profile.consult_in_group
		modes.push 'home' if profile.visit_home
		modes.push 'school' if profile.visit_school
		modes.push 'hospital' if profile.consult_at_hospital
		modes.push 'camp' if profile.consult_at_camp
		modes.join ', '
	end
	
	# Accepting new clients
	def profile_display_accepting_new_clients(profile)
		profile.accepting_new_clients ? 'Accepting new clients' : 'Not accepting new clients at this time'
	end
	
	# Search
	
	def search_query_string(search)
		q = search.try(:query).try(:to_params).try(:'[]', :q)
		q != '*:*' && q || ''
	end
	
	def search_area_tag_options(selected=nil)
		(anywhere_tag = SearchAreaTag.new).name = 'Anywhere'
		options_from_collection_for_select(SearchAreaTag.all_ordered.unshift(anywhere_tag), :id, :name, selected)
	end
	
	def search_results_title(search)
		(search.results.size > 0 ? "You searched for" : "No one found for") + " \"#{search_query_string(search)}\""
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
		profile.specialties_description.presence || display_profile_item_names(profile.specialties, 3)
	end
	
	def search_result_location(profile)
		loc = profile.locations.first
		[loc.try(:city).presence, loc.try(:region).presence].compact.join(', ')
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
		icons.join(' | ')
	end
	
	# Provider rating
	def provider_rating_title(rating)
		I18n.t "rating.score_#{rating.floor}"
	end
	
end
