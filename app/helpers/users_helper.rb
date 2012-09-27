module UsersHelper
	def profile_join_fields(field_array=[], separator=' ')
		field_array.map { |field|
				current_user.try(:profile).try(field).presence
			}.compact.join(separator)
	end
	
	def profile_address
		profile_join_fields [:address1, :address2, :city, :region, :country], ', '
	end
	
	def profile_country
		current_user.try(:profile).try(:country).presence || 'US'
	end
	
	def profile_display_name
		cred = current_user.try(:profile).try(:credentials)
		name = profile_join_fields [:first_name, :last_name], ' '
		name += ", #{cred}" if cred.present?
		name
	end
end
