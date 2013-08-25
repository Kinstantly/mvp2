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
	
	def user_display_name(user)
		user.username.presence || user.profile.try(:display_name_or_company).presence || t('views.user.view.no_name')
	end
	
	def user_profile_path(user)
		profile = user.profile
		profile && can?(:show, profile) ? profile_path(profile) : '#'
	end
	
	def user_profile_link(user)
		link_to user_display_name(user), user_profile_path(user)
	end
end
