class ProfileMailer < ActionMailer::Base
	include SendGrid #Allows custom X- headers for sendgrid
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	layout 'user_account_mailer'
	default from: MAILER_DEFAULT_FROM
	sendgrid_category :use_subject_lines # Set sendgrid category to email subject
	
	def default_invite(profile)
		@profile = profile
		sendgrid_unique_args :profile_id => @profile.id
		mail to: profile.invitation_email, from: 'Jim Scott <jscott@kinstantly.com>', subject: subject
	end

	def invite(email, subject, body)
		@body = body
		mail to: email, from: 'Jim Scott <jscott@kinstantly.com>', subject: subject
	end
end
