class StripeConnectMailer < ActionMailer::Base
	include SendGrid # Allows custom X- headers for sendgrid
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	helper :payment # Payment helpers.
	layout 'user_account_mailer'
	default from: MAILER_DEFAULT_FROM
	sendgrid_category :use_subject_lines # Set sendgrid category to email subject
	
	def welcome_provider(user)
		@user = user
		@profile = user.profile
		sendgrid_category :stripe_connect_welcome_provider
		@show_logo = true
		subject = "You're all set to accept online payments on Kinstantly"
		mail to: user.email, subject: subject
	end
end
