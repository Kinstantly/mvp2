# Extend the mailer which sends emails related to registration and authentication.
# Look for a layout for this mailer in app/views/layouts/user_account_mailer.html.haml.
class UserAccountMailer < Devise::Mailer
	include SendGrid #Setup custom X- header for sendgrid
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	sendgrid_category :use_subject_lines # Set sendgrid category to email subject

	# Send on non-provider account creation. Performs email address confirmation.
	def on_create_confirmation_instructions(record, token, opts={})
		@token = token
		devise_mail(record, :on_create_confirmation_instructions, opts)
	end
	
	# Send on provider account creation. Performs email address confirmation.
	def on_create_provider_confirmation_instructions(record, token, opts={})
		@token = token
		devise_mail(record, :on_create_provider_confirmation_instructions, opts)
	end
	
	# Send on account creation when signing up for the newsletter. Performs email address confirmation.
	def on_create_newsletter_confirmation_instructions(record, token, opts={})
		@token = token
		devise_mail(record, :on_create_newsletter_confirmation_instructions, opts)
	end
	
	# Send on account creation when signing up from the blog. Performs email address confirmation.
	def on_create_blog_confirmation_instructions(record, token, opts={})
		@token = token
		devise_mail(record, :on_create_blog_confirmation_instructions, opts)
	end
	
	# Send on user creation when claiming a profile, i.e., simple welcome email.
	def on_create_welcome(record, opts={})
		@show_logo = true
		devise_mail(record, :on_create_welcome, {reply_to: 'jscott@kinstantly.com'}.merge(opts))
	end
end
