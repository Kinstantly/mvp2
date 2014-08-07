class AdminMailer < ActionMailer::Base
	include SendGrid #Setup custom X- header for sendgrid
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	
	default from: MAILER_DEFAULT_FROM,
		to: PROFILE_MODERATOR_EMAIL,
		subject: 'Provider Profile updated on Kinstantly'
	
	# Notify profile moderator, when profile is updated.
	def on_update_alert(profile)
		@profile = profile
		sendgrid_category 'Profile Update Alert'
		sendgrid_unique_args :profile_id => @profile.id
		mail 
	end
	
	# Notify site admin, when a provider registers.
	def provider_registration_alert(user)
		@user, @profile = user, user.profile
		sendgrid_category 'Provider Registration Alert'
		mail subject: "Provider \"#{user.email}\" has registered", to: ADMIN_EMAIL
	end
	
	# Notify site admin, when a parent registers.
	def parent_registration_alert(user)
		@user = user
		sendgrid_category 'Parent Registration Alert'
		mail subject: "Parent \"#{user.email}\" has registered", to: ADMIN_EMAIL
	end
	
	# Notify the profile moderator, when a provider is suggested.
	def provider_suggestion_notice(provider_suggestion)
		@provider_suggestion = provider_suggestion
		subject = 'New provider suggestion'
		sendgrid_category subject
		sendgrid_unique_args provider_suggestion_id: provider_suggestion.to_param
		mail subject: subject
	end

	# Notify the profile moderator when profile claimed.
	def profile_claim_notice(profile_claim)
		@profile_claim = profile_claim
		subject = 'New profile claim has been submitted.'
		sendgrid_category subject
		sendgrid_unique_args profile_claim_id: profile_claim.to_param
		mail subject: subject
	end
end
