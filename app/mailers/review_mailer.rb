class ReviewMailer < ActionMailer::Base
	default from: MAILER_DEFAULT_FROM, 
			to: REVIEW_MODERATOR_EMAIL,
			subject: 'New Provider Review on Kinstantly'
	
	def notify_moderator(review)
		@review = review
		mail(subject: "New Review for #{@review.profile.display_name_or_company} by #{@review.reviewer_username}")
	end
end
