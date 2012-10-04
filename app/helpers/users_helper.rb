module UsersHelper
	def profile_join_fields(field_array=[], separator=' ', user=current_user)
		field_array.map { |field|
				user.try(:profile).try(field).presence
			}.compact.join(separator)
	end
	
	def profile_address(user=current_user)
		profile_join_fields [:address1, :address2, :city, :region, :country], ', ', user
	end
	
	def profile_country(user=current_user)
		user.try(:profile).try(:country).presence || 'US'
	end
	
	def profile_display_name(user=current_user)
		cred = user.try(:profile).try(:credentials)
		name = profile_join_fields [:first_name, :last_name], ' ', user
		name += ", #{cred}" if cred.present?
		name
	end
	
	def profile_age_ranges(user=current_user)
		age_ranges = user.try(:profile).try(:age_ranges).presence || []
		age_ranges.map{|a| a.name}.join(', ')
	end
end
