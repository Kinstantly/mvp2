module ProfilesHelper
	def location_display_address(location=current_user.try(:profile).try(:locations).try(:first))
		location.try(:display_address).presence || ''
	end
	
	def display_profile_item_names(items, n=items.try(:length))
		items.collect(&:name).sort{|a, b| a.casecmp b}.slice(0, n).join(', ') if items.present?
	end
	
	def default_profile_country
		'US'
	end
	
	def profile_country(profile=current_user.try(:profile))
		profile.try(:locations).try(:first).try(:country).presence || default_profile_country
	end
	
	def profile_display_name(profile=current_user.try(:profile))
		profile.try(:display_name).presence || ''
	end
	
	def profile_age_ranges(profile=current_user.try(:profile))
		age_ranges = profile.try(:age_ranges).presence || []
		age_ranges.sort_by(&:sort_index).map(&:name).join(', ')
	end
		
	def profile_attribute_tag_name(attr_name, form_builder=nil)
		"#{form_builder.object_name.presence || 'profile'}[#{attr_name}][]"
	end
	
	def edit_profile_link(profile)
		link_to "Edit profile", edit_profile_path(profile) if can?(:update, profile)
	end
	
	def profile_publish_check_box(profile)
		tag_name = 'is_published'
		hidden_field_tag(tag_name, '', id: 'is_published_not') +
			check_box_tag(tag_name, '1', profile.is_published, id: 'is_published')
	end
	
	def profile_list_view_link(profile, name)
		if can?(:read, profile)
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
	
	def profile_categories_services_info(profile)
		map = {}
		names = {}
		(Category.predefined + profile.categories).uniq.each { |cat|
			map[cat.id] = cat.services.collect(&:id)
			cat.services.each { |svc| names[svc.id] = svc.name.html_escape unless names[svc.id] }
		}
		[map, names]
	end

	def profile_services_specialties_info(profile)
		map = {}
		names = {}
		(Service.predefined + profile.services).uniq.each { |svc|
			map[svc.id] = svc.specialties.collect(&:id)
			svc.specialties.each { |spec| names[spec.id] = spec.name.html_escape unless names[spec.id] }
		}
		[map, names]
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
		radio_button_tag profile_categories_tag_name(form_builder), category.id, profile.categories.include?(category), id: profile_categories_id(category.id)
	end
	
	def profile_display_categories(profile=current_user.try(:profile))
		display_profile_item_names profile.try(:categories)
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
		content_tag :div, class: wrapper_class do
			check_box_tag(profile_services_tag_name(form_builder), id, checked, id: profile_services_id(id)) + " #{name}"
		end
	end
	
	def profile_services_check_box_cache(profile, wrapper_class, form_builder=nil)
		cache = {}
		profile.services.uniq.each do |svc|
			cache[svc.id] = profile_services_check_box profile, svc.id, svc.name, true, wrapper_class, form_builder
		end
		cache
	end
	
	def profile_display_services(profile=current_user.try(:profile))
		display_profile_item_names profile.try(:services)
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
		content_tag :div, class: wrapper_class do
			check_box_tag(profile_specialties_tag_name(form_builder), id, checked, id: profile_specialties_id(id)) + " #{name}"
		end
	end
	
	def profile_specialties_check_box_cache(profile, wrapper_class, form_builder=nil)
		cache = {}
		profile.specialties.uniq.each do |spec|
			cache[spec.id] = profile_specialties_check_box profile, spec.id, spec.name, true, wrapper_class, form_builder
		end
		cache
	end
		
	def profile_display_specialties(profile=current_user.try(:profile))
		display_profile_item_names profile.try(:specialties)
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
	
	# Consultations and visits
	
	def profile_display_consultation_modes(profile)
		return '' unless profile
		modes = []
		modes.push 'email' if profile.consult_by_email
		modes.push 'phone' if profile.consult_by_phone
		modes.push 'video' if profile.consult_by_video
		modes.join ', '
	end
	
	def profile_display_visitation_modes(profile)
		return '' unless profile
		modes = []
		modes.push 'home' if profile.visit_home
		modes.push 'school' if profile.visit_school
		modes.join ', '
	end
	
	# Accepting new clients
	def profile_display_accepting_new_clients(profile)
		profile.accepting_new_clients ? 'Accepting new clients' : 'Not accepting new clients at this time'
	end
	
	# Search
	
	def search_results_title(search)
		n = search.results.size
		query = search.query.to_params[:q]
		n > 0 ? "#{'Expert'.pluralize(n)} matching \"#{query}\"" : "No experts match \"#{query}\""
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
		display_profile_item_names profile.specialties, 3
	end
	
	def search_result_location(profile)
		loc = profile.locations.first
		[[loc.try(:city).presence, loc.try(:region).presence].compact.join(', ').presence, loc.try(:postal_code).presence].compact.join(' ')
	end
	
	def search_result_consultations_visits(profile)
		icons = []
		icons << 'email' if profile.consult_by_email
		icons << 'phone' if profile.consult_by_phone
		icons << 'video' if profile.consult_by_video
		icons << 'home' if profile.visit_home
		icons << 'school' if profile.visit_school
		icons.join(' | ')
	end
end
