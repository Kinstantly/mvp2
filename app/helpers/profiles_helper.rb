module ProfilesHelper
	def profile_join_fields(field_array=[], separator=' ', profile=current_user.try(:profile))
		field_array.map { |field|
				profile.try(field).presence
			}.compact.join(separator)
	end
	
	def profile_address(profile=current_user.try(:profile))
		profile_join_fields [:address1, :address2, :city, :region, :country], ', ', profile
	end
	
	def default_profile_country
		'US'
	end
	
	def profile_country(profile=current_user.try(:profile))
		profile.try(:country).presence || default_profile_country
	end
	
	def profile_display_name(profile=current_user.try(:profile))
		cred = profile.try(:credentials)
		name = profile_join_fields [:first_name, :middle_name, :last_name], ' ', profile
		name += ", #{cred}" if cred.present?
		name
	end
	
	def profile_age_ranges(profile=current_user.try(:profile))
		age_ranges = profile.try(:age_ranges).presence || []
		age_ranges.map{|a| a.name}.join(', ')
	end
		
	def profile_attribute_tag_name(attr_name, form_builder=nil)
		"#{form_builder.object_name.presence || 'profile'}[#{attr_name}][]"
	end
	
	def profile_categories_specialties_map
		Profile.categories_specialties_map
	end

	# Categories helpers
	
	def profile_predefined_categories
		Profile.predefined_categories
	end
	
	def profile_categories_id(s)
		"profile_categories_#{s.to_alphanumeric}"
	end
	
	def profile_categories_tag_name(form_builder=nil)
		profile_attribute_tag_name 'categories_updater', form_builder
	end
	
	def profile_categories_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_categories_tag_name(form_builder), '', id: profile_categories_id('hidden_field')
	end
	
	def profile_categories_check_box_tag(profile, category, form_builder=nil)
		check_box_tag profile_categories_tag_name(form_builder), category, profile.categories.include?(category), id: profile_categories_id(category)
	end
	
	def profile_display_categories(profile=current_user.try(:profile))
		profile.categories.join(', ')
	end
	
	def profile_custom_categories_id(s)
		profile_categories_id "custom_#{s}"
	end
	
	def profile_custom_categories_tag_name(form_builder=nil)
		profile_attribute_tag_name 'categories_merger', form_builder
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
	
	def profile_specialties_id(s)
		"profile_specialties_#{s.to_alphanumeric}"
	end
	
	def profile_specialties_tag_name(form_builder=nil)
		profile_attribute_tag_name 'specialties_updater', form_builder
	end
	
	def profile_specialties_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_specialties_tag_name(form_builder), '', id: profile_specialties_id('hidden_field')
	end
	
	def profile_specialties_check_box_tag(profile, specialty, form_builder=nil)
		check_box_tag profile_specialties_tag_name(form_builder), specialty, profile.specialties.include?(specialty), id: profile_specialties_id(specialty)
	end
	
	def profile_specialties_check_box_tag_cache(profile, form_builder=nil)
		cache = {}
		Profile.categories_specialties_map.each do |cat, specs|
			specs.each do |spec|
				cache[spec] = profile_specialties_check_box_tag(profile, spec, form_builder) unless cache[spec]
			end
		end
		cache
	end
		
	def profile_display_specialties(profile=current_user.try(:profile))
		profile.specialties.join(', ')
	end
	
	def profile_custom_specialties_id(s)
		profile_specialties_id "custom_#{s}"
	end
	
	def profile_custom_specialties_tag_name(form_builder=nil)
		profile_attribute_tag_name 'specialties_merger', form_builder
	end
	
	def profile_custom_specialties_hidden_field_tag(form_builder=nil)
		hidden_field_tag profile_custom_specialties_tag_name(form_builder), '', id: profile_custom_specialties_id('hidden_field')
	end
	
	def profile_custom_specialties_text_field_tag(profile, value, suffix, form_builder=nil)
		text_field_tag profile_custom_specialties_tag_name(form_builder), value, id: profile_custom_specialties_id(suffix)
	end
end
