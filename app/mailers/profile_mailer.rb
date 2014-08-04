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

	def invite(email, subject, body, profile, delivery_token, test_invitation=false)
		@body = body.gsub(' -- ', ' &mdash; ').gsub("<<claim_url>>", claim_user_profile_url(token: profile.invitation_token))
		@unsubscribe_url = new_contact_blocker_from_email_delivery_url email_delivery_token: delivery_token
		if test_invitation
			sendgrid_category :invitation_preview
		elsif profile.invitation_tracking_category.present?
			sendgrid_category profile.invitation_tracking_category
		end
		mail to: email, from: 'Jim Scott <jscott@kinstantly.com>', subject: subject
	end
end
