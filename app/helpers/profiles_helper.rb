module ProfilesHelper
	def join_fields(field_array=[], separator=' ', obj=nil)
		field_array.map { |field|
				obj.try(field).presence
			}.compact.join(separator)
	end
	
	def location_display_address(location=current_user.try(:profile).try(:locations).try(:first))
		addr = join_fields [:address1, :address2, :city, :region, :country], ', ', location
		postal_code = location.try(:postal_code)
		addr += " #{postal_code}" if postal_code.present?
		addr
	end
	
	def display_profile_item_names(items)
		items.collect(&:name).sort{|a, b| a.casecmp b}.join(', ') if items.present?
	end
	
	def default_profile_country
		'US'
	end
	
	def profile_country(profile=current_user.try(:profile))
		profile.try(:locations).try(:first).try(:country).presence || default_profile_country
	end
	
	def profile_display_name(profile=current_user.try(:profile))
		cred = profile.try(:credentials)
		name = join_fields [:first_name, :middle_name, :last_name], ' ', profile
		name += ", #{cred}" if cred.present?
		name
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
	
	def profile_categories_specialties_info(profile)
		map = {}
		names = {}
		(Category.predefined + profile.categories).uniq.each { |cat|
			map[cat.id] = cat.specialties.collect(&:id)
			cat.specialties.each { |spec| names[spec.id] = spec.name unless names[spec.id] }
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
		check_box_tag profile_categories_tag_name(form_builder), category.id, profile.categories.include?(category), id: profile_categories_id(category.id)
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
	
	# Specialties helpers
	
	def profile_predefined_specialties
		Profile.predefined_specialties
	end
	
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
end
