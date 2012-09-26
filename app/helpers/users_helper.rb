module UsersHelper
	def profile_address
		[:address1, :address2, :city, :region, :country].map { |field|
				current_user.try(:profile).try(field).presence
			}.compact.join(', ')
	end
end
