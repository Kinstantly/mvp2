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
		subject = "You have authorized payments via Kinstantly"
		mail to: @user.email, subject: subject
	end
end
