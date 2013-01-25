class ProfileMailer < ActionMailer::Base
	default from: MAILER_DEFAULT_FROM, bcc: MAILER_DEFAULT_BCC
	
	def invite(profile)
		@profile = profile
		mail to: profile.invitation_email
	end
end
