class AdminMailer < ActionMailer::Base
	default from: MAILER_DEFAULT_FROM,
		to: PROFILE_MODERATOR_EMAIL,
		subject: 'Provider Profile updated on Kinstantly'
	
	# Notify site admin, when profile is updated.
	def on_update_alert(profile)
		@profile = profile
		mail
	end
end
