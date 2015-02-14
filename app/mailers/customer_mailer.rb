class CustomerMailer < ActionMailer::Base
	include SendGrid # Allows custom X- headers for sendgrid
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	helper :payment # Payment helpers.
	layout 'user_account_mailer'
	default from: MAILER_DEFAULT_FROM
	sendgrid_category :use_subject_lines # Set sendgrid category to email subject
	
	def confirm_authorized_amount(customer_file)
		@customer_file = customer_file
		@user = customer_file.customer.user
		@provider_profile = customer_file.provider.profile
		sendgrid_category :confirm_authorized_amount
		@show_logo = true
		subject = "You've authorized payments via Kinstantly"
		mail to: @user.email, subject: subject
	end
	
	def confirm_revoked_authorization(customer_file)
		@customer_file = customer_file
		@user = customer_file.customer.user
		@provider_profile = customer_file.provider.profile
		sendgrid_category :confirm_revoked_authorization
		@show_logo = true
		subject = "You've revoked payment authorization"
		mail to: @user.email, subject: subject
	end
	
	def notify_provider_of_payment_authorization(customer_file)
		@customer_file = customer_file
		@provider = customer_file.provider
		@provider_name = @provider.try(:profile).try(:first_name)
		sendgrid_category :notify_provider_of_payment_authorization
		@show_logo = true
		subject = "A customer has authorized payments to you"
		mail to: @provider.email, subject: subject
	end
	
	def notify_provider_of_revoked_authorization(customer_file)
		@customer_file = customer_file
		@provider = customer_file.provider
		@provider_name = @provider.try(:profile).try(:first_name)
		sendgrid_category :notify_provider_of_revoked_authorization
		@show_logo = true
		subject = "A customer has revoked payment authorization"
		mail to: @provider.email, subject: subject
	end
end
