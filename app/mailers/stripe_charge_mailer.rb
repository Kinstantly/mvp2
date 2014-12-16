class StripeChargeMailer < ActionMailer::Base
	include SendGrid # Allows custom X- headers for sendgrid
	helper :mailer # Access to MailerHelper methods in this mailer's views.
	helper :payment # Payment helpers.
	layout 'user_account_mailer'
	default from: MAILER_DEFAULT_FROM
	sendgrid_category :use_subject_lines # Set sendgrid category to email subject
	
	def notify_customer(stripe_charge)
		@stripe_charge = stripe_charge
		@customer_file = @stripe_charge.customer_file
		@user = @customer_file.customer_user
		@provider_profile = @customer_file.provider.profile
		sendgrid_category :customer_charge_notification
		@show_logo = true
		subject = "Kinstantly Provider Charge Notification"
		mail to: @user.email, subject: subject
	end
	
	def notify_customer_of_refund(stripe_charge)
		@stripe_charge = stripe_charge
		@customer_file = @stripe_charge.customer_file
		@user = @customer_file.customer_user
		@provider_profile = @customer_file.provider.profile
		sendgrid_category :customer_refund_notification
		@show_logo = true
		subject = "Kinstantly Provider Refund Notification"
		mail to: @user.email, subject: subject
	end
end
