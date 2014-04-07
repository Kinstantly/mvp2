class AdminMailer < ActionMailer::Base
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	
	default from: MAILER_DEFAULT_FROM,
		to: PROFILE_MODERATOR_EMAIL,
		subject: 'Provider Profile updated on Kinstantly'
	
	# Notify profile moderator, when profile is updated.
	def on_update_alert(profile)
		@profile = profile
		mail
	end
	
	# Notify site admin, when a provider registers.
	def provider_registration_alert(user)
		@user, @profile = user, user.profile
		mail subject: "Provider \"#{user.email}\" has registered", to: ADMIN_EMAIL
	end
	
	# Notify site admin, when a parent registers.
	def parent_registration_alert(user)
		@user = user
		mail subject: "Parent \"#{user.email}\" has registered", to: ADMIN_EMAIL
	end
end
