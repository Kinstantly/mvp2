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
		
		id_pattern = /\A\w+\z/
		@errors << 'A valid list must be specified.' if list_id !~ id_pattern
		@errors << 'A valid folder for the sent campaigns must be specified.' if folder_id !~ id_pattern
		return (@successful = false) if @errors.present?
		
		# For each stage:
		SubscriptionStage.where(list_id: list_id).each do |stage|
			begin
				next unless stage.trigger_delay_days
				
				recipients = pending_recipients stage, list_id
				next if recipients.blank?
				
				segment = create_recipient_segment recipients, stage
				next unless segment['member_count'] > 0
				
				campaign = create_campaign stage, segment, folder_id
				schedule_campaign campaign
				
				log_delivery segment, campaign, stage
				
			rescue Gibbon::MailChimpError => e
				@errors << "Error while sending stage #{stage.id}: #{e.title}; #{e.detail}; status: #{e.status_code}; subscription stage: #{stage.inspect}"
			end
		end
		
		@successful
	end
	
	def successful?
		@successful
	end
	
	private
	
	def pending_recipients(subscription_stage, list_id)
		
		# Keep trying for several days after initial eligibility of recipients,
		# in case we missed a day or more of running this service.
		delay_days_max = subscription_stage.trigger_delay_days + 7
		delay_days_min = subscription_stage.trigger_delay_days - 1
		
		# Look back this many days when checking for relevant subscription_deliveries.
		# This value should always be more than the range of days we keep looking for recipients.
		days_of_lookback = (delay_days_max - delay_days_min) + 4
		
		s = "(SELECT subscriptions.* FROM subscriptions WHERE
		      subscriptions.subscribed IS TRUE
		      AND
		      subscriptions.list_id = '#{list_id}'
		      AND
		      (subscriptions.birth1 BETWEEN
		         CURRENT_DATE - #{delay_days_max} AND CURRENT_DATE - #{delay_days_min}
		       OR
		       subscriptions.birth2 BETWEEN
		         CURRENT_DATE - #{delay_days_max} AND CURRENT_DATE - #{delay_days_min}
		       OR
		       subscriptions.birth3 BETWEEN
		         CURRENT_DATE - #{delay_days_max} AND CURRENT_DATE - #{delay_days_min}
		       OR
		       subscriptions.birth4 BETWEEN
		         CURRENT_DATE - #{delay_days_max} AND CURRENT_DATE - #{delay_days_min}))
		   EXCEPT
		   (SELECT subscriptions.* FROM subscriptions, subscription_deliveries WHERE
		      subscriptions.id = subscription_deliveries.subscription_id
		      AND
		      subscriptions.list_id = '#{list_id}'
		      AND
		      subscription_deliveries.subscription_stage_id = #{subscription_stage.id}
		      AND
		      subscription_deliveries.created_at > CURRENT_DATE - #{days_of_lookback})"

		Subscription.find_by_sql(s)
	end
	
	def create_recipient_segment(subscriptions, subscription_stage)
		emails = subscriptions.map &:email
		body = {
			name: "#{subscription_stage.title} #{Time.zone.now.to_s}",
			static_segment: emails
		}
		
		Gibbon::Request.lists(subscription_stage.list_id).segments.create body: body
	end
	
	def create_campaign(subscription_stage, segment, folder_id)
		
	end
	
	def schedule_campaign(campaign)
		
	end
	
	def log_delivery(segment, campaign, subscription_stage)
		
	end
end
