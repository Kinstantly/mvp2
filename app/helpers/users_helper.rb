module UsersHelper
	def user_list_profile_link_id(profile)
		"profile_#{profile.id}"
	end
	
	def user_list_profile_link(profile=nil)
		if profile
			link_to profile.is_published ? 'Published' : 'Not published', profile_path(profile), id: user_list_profile_link_id(profile)
		else
			'No profile!'
		end
	end
end
