# Extend the mailer which sends emails related to registration and authentication.
# Look for a layout for this mailer in app/views/layouts/user_account_mailer.html.haml.
class UserAccountMailer < Devise::Mailer
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	
	# Send on user creation, i.e., welcome email which also performs email address confirmation.
	def on_create_confirmation_instructions(record, opts={})
		devise_mail(record, :on_create_confirmation_instructions, opts)
	end
	
	# Send on user creation when claiming a profile, i.e., simple welcome email.
	def on_create_welcome(record, opts={})
		devise_mail(record, :on_create_welcome, opts)
	end
end
