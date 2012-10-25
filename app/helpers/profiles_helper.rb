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
	
	def profile_categories_id(category)
		"categories_#{to_alphanumeric(category)}"
	end
	
	def profile_categories_tag_name(nested=false)
		nested ? 'user[profile_attributes][categories_updater][]' : 'profile[categories_updater][]'
	end
	
	def profile_categories_hidden_field_tag(nested=false)
		hidden_field_tag profile_categories_tag_name(nested), '', id: 'profile_categories_hidden_field'
	end
	
	def profile_categories_check_box_tag(profile, category, nested=false)
		check_box_tag profile_categories_tag_name(nested), category, profile.categories.include?(category), id: profile_categories_id(category)
	end
	
	def profile_display_categories(profile=current_user.try(:profile))
		profile.categories.join(', ')
	end
end
