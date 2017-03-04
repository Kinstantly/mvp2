class StageNewsletterSender
	
	include SiteConfigurationHelpers
	
	attr_reader :params, :errors, :total_campaigns_scheduled, :total_recipients, :time_string_format, :batch_size
	
	def initialize(params)
		@params = params
		@errors = []
		@total_campaigns_scheduled = @total_recipients = 0
		@time_string_format = '%Y-%m-%dT%H:%M:%S%:z'
		@batch_size = 50
		@successful = true
	end
	
	def call
		list_id = mailchimp_list_ids[params[:list]]
		folder_id = mailchimp_folder_ids[params[:folder]]
		@batch_size = params[:batch_size].to_i if params[:batch_size].present?
		
		id_pattern = /\A\w+\z/
		@errors << 'A valid list must be specified.' if list_id !~ id_pattern
		@errors << 'A valid folder for the sent campaigns must be specified.' if folder_id !~ id_pattern
		@errors << 'A valid batch size must be specified' unless batch_size > 0
		return (@successful = false) if @errors.present?
		
		# For each stage:
		SubscriptionStage.where(list_id: list_id).each do |stage|
			begin
				next unless stage.trigger_delay_days
				
				recipients = pending_recipients stage, list_id
				next if recipients.blank?
				
				segment = create_recipient_segment recipients, stage
				next unless segment['member_count'] > 0 # MailChimp might have rejected all of them!
				
				campaign = create_campaign stage, segment, folder_id
				
				scheduled = schedule_campaign campaign
				if scheduled['status'] != 'schedule'
					@errors << "Error: failed to schedule '#{stage.title}'; NOT logging delivery; campaign ID => #{scheduled['id']}, campaign title => '#{scheduled['settings']['title']}'"
					next
				end
				
				@total_recipients += log_delivery segment, scheduled, stage
				
				@total_campaigns_scheduled += 1
				
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
			name: "#{subscription_stage.title}: #{Time.zone.now.to_s}",
			static_segment: emails
		}
		
		Gibbon::Request.lists(subscription_stage.list_id).segments.create body: body
	end
	
	def create_campaign(subscription_stage, segment, folder_id)
		campaign = Gibbon::Request.campaigns(subscription_stage.source_campaign_id).actions.replicate.create
		
		Gibbon::Request.campaigns(campaign['id']).update body: {
			recipients: {
				list_id: subscription_stage.list_id,
				segment_opts: { saved_segment_id: segment['id'] }
			},
			settings: {
				title: "#{subscription_stage.title}: #{Time.zone.now.to_s}",
				folder_id: mailchimp_folder_ids[:parent_newsletters_campaigns],
				to_name: '*|FNAME|*'
			}
		}
	end
	
	def schedule_campaign(campaign)
		# Let's start with 8am today in the time zone configured for this application.
		# See Rails.configuration.time_zone.
		schedule_time = Time.zone.now.midnight + 8.hours
		if schedule_time < Time.zone.now + 1.hour
			# Too late to schedule for 8am today. Try for tomorrow.
			schedule_time += 1.day
		end
		# Specify as a UTC string.
		schedule_time_utc = schedule_time.utc.strftime(time_string_format)
		
		Gibbon::Request.campaigns(campaign['id']).actions.schedule.create body: {
			schedule_time: schedule_time_utc,
			timewarp: false,
			batch_delay: false
		}
		# FYI, the above request does not return the campaign.
		
		Gibbon::Request.campaigns(campaign['id']).retrieve
	end
	
	def log_delivery(segment, campaign, subscription_stage)
		list_id = subscription_stage.list_id
		segment_id = segment['id']
		
		# We need to loop, because MailChimp always retrieves members in batches.
		offset = 0
		total = segment['member_count']
		retrieved = 0
		
		while retrieved < total
			response = Gibbon::Request.lists(list_id).segments(segment_id).members.retrieve params: {
				count: "#{batch_size}",
				offset: "#{offset}"
			}
			offset += batch_size
			
			members = response['members']
			break if members.blank? # In case of kookiness and we've run out before we reached the total.
			retrieved += members.size
			
			members.each do |member|
				begin
					email = member['email_address']
					subscription = Subscription.where(email: email, list_id: list_id).first
				
					SubscriptionDelivery.create!(
						email: email,
						subscription: subscription,
						subscription_stage: subscription_stage,
						source_campaign_id: subscription_stage.source_campaign_id,
						campaign_id: campaign['id'],
						schedule_time: Time.zone.parse(campaign['send_time'])
					)
				rescue ActiveRecord::RecordInvalid => invalid
					invalid.record.errors.full_messages.each do |message|
						@errors << "Log delivery error: #{message}: list_id => #{list_id}, segment_id => #{segment_id}"
					end
				end
			end
		end
		
		if retrieved == 0
			@errors << "Log delivery error: no segment members found: list_id => #{list_id}, segment_id => #{segment_id}"
		end
		
		retrieved
	end
end
