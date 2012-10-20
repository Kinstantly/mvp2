module UsersHelper
	def user_profile_address(user=current_user)
		profile_address user.try(:profile)
	end
	
	def user_profile_country(user=current_user)
		profile_country user.try(:profile)
	end
	
	def user_profile_display_name(user=current_user)
		profile_display_name user.try(:profile)
	end
	
	def user_profile_age_ranges(user=current_user)
		profile_age_ranges user.try(:profile)
	end
end
