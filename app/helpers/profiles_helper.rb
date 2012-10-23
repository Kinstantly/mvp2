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
end
