class ProfileMailer < ActionMailer::Base
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	layout 'user_account_mailer'
	default from: MAILER_DEFAULT_FROM
	
	def invite(profile)
		@profile = profile
		mail to: profile.invitation_email, from: 'Jim Scott <jscott@kinstantly.com>', category: 'profile_invite'
	end
end
