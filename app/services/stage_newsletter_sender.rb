class StageNewsletterSender
	
	include SiteConfigurationHelpers
	
	attr_reader :params, :errors, :total_campaigns_sent, :total_recipients
	
	def initialize(params)
		@params = params
		@errors = []
		@total_campaigns_sent = @total_recipients = 0
		@successful = true
	end
	
	def call
		list_id = mailchimp_list_ids[params[:list]]
		folder_id = mailchimp_folder_ids[params[:folder]]
		
		@errors << 'A valid list must be specified.' if list_id.blank?
		@errors << 'A valid folder for the sent campaigns must be specified.' if folder_id.blank?
		return (@successful = false) if @errors.present?
		
		# do stuff here
		
		@successful
	end
	
	def successful?
		@successful
	end
	
	private
	
	
end
