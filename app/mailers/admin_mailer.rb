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

	# Notify site admin, when user subscribes to alerts without creating an account.
	def alerts_subscribe_alert(subscriptions, email, options={})
		@subscriptions = subscriptions
		@email = email
		@duebirth1 = options[:merge_vars].try :[], 'DUEBIRTH1'
		@newsletter_name = t 'views.newsletter.name'
		sendgrid_category "#{@newsletter_name}-only Subscription Alert"
		mail subject: "#{@newsletter_name} sign-up from directory site", to: ADMIN_EMAIL
	end

	# Notify site admin, when user subscribes to newsletters without creating an account.
	def newsletter_subscribe_alert(subscriptions, email)
		@subscriptions = subscriptions
		@email = email
		sendgrid_category 'Newsletter-only Subscription Alert'
		mail subject: "New newsletter subscriber: #{email} ", to: ADMIN_EMAIL
	end

	# Notify site admin, when mailchimp subscriber unsubscribes from newsletters.
	def newsletter_unsubscribe_alert(subscription, email)
		@list_name = User.human_attribute_name subscription
		@email = email
		sendgrid_category 'Newsletter Unsubscribe Alert'
		mail subject: "User with email #{email} has unsubscribed from \"#{@list_name}\" newsletters", to: ADMIN_EMAIL
	end

	# Notify site admin, when a mailchimp subscriber was deleted from a newsletter list.
	def newsletter_subscriber_delete_alert(subscription, email)
		@list_name = User.human_attribute_name subscription
		@email = email
		sendgrid_category 'Newsletter Subscriber Delete Alert'
		mail subject: "User with email #{email} was deleted from \"#{@list_name}\" newsletter list", to: ADMIN_EMAIL
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
