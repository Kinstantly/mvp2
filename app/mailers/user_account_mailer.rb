# Extend the mailer which sends emails related to registration and authentication.
class UserAccountMailer < Devise::Mailer
	# Send on user creation, i.e., welcome email which also performs email address confirmation.
	def on_create_confirmation_instructions(record, opts={})
		devise_mail(record, :on_create_confirmation_instructions, opts)
	end
end
