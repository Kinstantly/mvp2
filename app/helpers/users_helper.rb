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
		user.username.presence || t('views.user.view.no_name')
	end
	
	def user_profile_path(user)
		'#'
		# profile = user.profile
		# profile && can?(:show, profile) ? profile_path(profile) : '#'
	end
	
	def user_profile_link(user)
		link_to user_display_name(user), user_profile_path(user)
	end
	
	# Return a string or time suitable for displaying when the user's confirmation email was sent.
	# If nothing useful to show, returns nil.
	def user_confirmation_sent_at(user)
		if Rails.configuration.running_as_private_site
			sent_at, sent_by = user.admin_confirmation_sent_at, user.admin_confirmation_sent_by
			if sent_at
				"#{sent_at} by #{sent_by.try :email}"
			elsif user.confirmed?
				user.confirmation_sent_at # self-confirmed
			end
		else
			user.confirmation_sent_at
		end
	end
end
