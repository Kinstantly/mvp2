# Use this class to subscribe an email address to the specified MailChimp lists.  The lists must be configured in Rails.configuration.mailchimp_list_id.
# To run immediately: NewsletterSubscriptionJob.new(lists_array, email).perform
# To queue for background processing: Delayed::Job.enqueue NewsletterSubscriptionJob.new(lists_array, email)
NewsletterSubscriptionJob = Struct.new(:lists, :email) do
	def perform
		NewslettersController.subscribe_to_mailing_lists(lists, email)
		Rails.logger.try :info, "#{self.class} finished: lists => #{lists.inspect}, email => #{email}"
	end
end
