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
		name = profile_join_fields [:first_name, :middle_initial, :last_name], ' ', profile
		name += ", #{cred}" if cred.present?
		name
	end
	
	def profile_age_ranges(profile=current_user.try(:profile))
		age_ranges = profile.try(:age_ranges).presence || []
		age_ranges.map{|a| a.name}.join(', ')
	end
	
	def profile_categories
		['addiction therapist', 'allergist', 'baby-proofing/home safety consultant', 'babysitter/mother\'s helper', 'bachelor\'s-level therapist', 'board-certified behavior analyst', 'child/clinical psychologist', 'child psychiatrist', 'college admissions prep', 'college financial aid counselor', 'couples/family therapist', 'developmental-behavioral pediatrician', 'doula', 'eating disorders specialist', 'fertility specialist', 'genetics counselor', 'home allergens inspector', 'lactation/feeding consultant/counselor', 'learning disabilities specialist', 'master\'s-level therapist', 'midwife', 'music instructor', 'nutritionist', 'ob-gyn', 'occupational therapist', 'parenting coach/educator', 'pediatrician', 'pediatric dentist', 'physical therapist', 'reading/dyslexia specialist', 'school advocate', 'sleep expert', 'speech therapist', 'tutor', 'other']
	end
	
	def profile_categories_id(s)
		"profile_categories_#{s.to_alphanumeric}"
	end
	
	def profile_attribute_tag_name(attr_name, form_builder=nil)
		"#{form_builder.object_name.presence || 'profile'}[#{attr_name}][]"
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
end
