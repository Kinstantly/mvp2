class ReviewMailer < ActionMailer::Base
	include SendGrid #Setup custom X- header for sendgrid
	default from: MAILER_DEFAULT_FROM, 
			to: REVIEW_MODERATOR_EMAIL,
			subject: 'New Provider Review on Kinstantly'
	sendgrid_category 'New Review Alert'

	def notify_moderator(review)
		@review = review
		sendgrid_unique_args :profile_id => @review.profile.id
		mail(subject: "New Review for #{@review.profile.display_name_or_company} by #{@review.reviewer_username}")
	end
end
