class MailchimpWebhookController < ApplicationController
	SECURITY_TOKEN = Rails.configuration.mailchimp_webhook_security_token
	EVENT_KEY = "type"
	DATA_KEY = "data"

	protect_from_forgery except: :process_notification
	
	def process_notification
		type = params[EVENT_KEY]
		data = params[DATA_KEY]

		if incoming_data_valid?(params) && token_valid?(params)
			case type
			when 'unsubscribe'
				on_unsubscribe data
			when 'campaign'
				on_campaign_sent data
			else
				logger.error "MailChimp Webhook error: unexpected incoming notification. Params: #{params}" if logger
			end
		else
			logger.error "MailChimp Webhook error: invalid incoming notification. Params: #{params}" if logger
		end
		render :nothing => true
	end
	
	private

	def on_unsubscribe(data)
		incoming_list_id = data['list_id']
		subscriber_email = data['email']
		
		if incoming_list_id.blank? or incoming_list_id !~ /\A\w+\z/
			logger.error "MailChimp Webhook error: list ID is not valid; list ID => #{incoming_list_id}"
			return
		end
		if subscriber_email.blank? or subscriber_email !~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
			logger.error "MailChimp Webhook error: subscriber email is not valid; email => #{subscriber_email}"
			return
		end
		
		list_name = mailchimp_list_ids.key(incoming_list_id)

		if !User.mailing_list_name_valid?(list_name)
			logger.error "MailChimp Webhook unsubscribe verification error: incoming_list_id \'#{incoming_list_id}\' is not valid. List name: #{list_name}." if logger
			return
		end
		if data['reason'] == 'abuse'
			logger.info "MailChimp Webhook: user reported abuse: email => #{subscriber_email}" if logger
		end
		
		begin
			r = Gibbon::Request.lists(incoming_list_id).members(email_md5_hash(subscriber_email)).retrieve
			if r.present?
				case r['status']
				when 'unsubscribed', 'cleaned'
					if (user = User.find_by_email_ignore_case(subscriber_email))
						user.process_unsubscribe_event(list_name)
					end
					AdminMailer.newsletter_unsubscribe_alert(list_name, subscriber_email).deliver_now
				else
					logger.error "MailChimp Webhook unsubscribe verification error. MailChimp response: #{r}" if logger
				end
			else
				logger.info "MailChimp Webhook unsubscribe: No member_info for list_name => #{list_name}, email => #{subscriber_email}" if logger
			end
		rescue Gibbon::MailChimpError => e
			if e.status_code == 404 # No subscription record at MailChimp; probably was deleted.
				if (user = User.find_by_email_ignore_case(subscriber_email))
					user.process_unsubscribe_event(list_name)
				end
				# AdminMailer.newsletter_delete_alert(list_name, subscriber_email).deliver_now
				AdminMailer.newsletter_unsubscribe_alert(list_name, subscriber_email).deliver_now
				logger.info "MailChimp Webhook unsubscribe: No subscription record for list_name => #{list_name}, email => #{subscriber_email}; was most likely deleted rather than unsubscribed" if logger
			else
				logger.error "MailChimp Webhook error while processing notification: #{e.title}; #{e.detail}; status: #{e.status_code}; email: #{subscriber_email}" if logger
			end
		end
	end
	
	def incoming_data_valid?(params)
		params[EVENT_KEY].present? && params[DATA_KEY].present?
	end

	def token_valid?(params)
		params['token'].present? && params['token'] == SECURITY_TOKEN
	end

	def folder_id_skip_list
		[
			mailchimp_folder_ids[:parent_newsletters_campaigns],
			mailchimp_folder_ids[:parent_newsletters_source_campaigns]
		]
	end

	def on_campaign_sent(data)
		id = data['id']
		if id.blank? or id !~ /\A\w+\z/
			logger.error "MailChimp Webhook error: campaign ID is not valid; campaign ID => #{id}"
			return
		end
		
		campaign_info = retrieve_campaign_info(id)
		if campaign_info.blank?
			logger.error "MailChimp Webhook error: could not retrieve info for campaign ID => #{id}; campaign_info => #{campaign_info}"
			return
		end
		
		mark_campaign_as_sent campaign_info
		archive_campaign campaign_info
	end
	
	def mark_campaign_as_sent(campaign_info)
		id = campaign_info['id']
		
		send_time_string = campaign_info['send_time'] || ''
		send_time = Time.zone.parse send_time_string
		
		unless send_time
			logger.error "MailChimp Webhook error: could not parse send_time for campaign ID => #{id}; campaign_info => #{campaign_info}"
			return
		end
		
		SubscriptionDelivery.where(campaign_id: id).find_each do |subscription_delivery|
			unless subscription_delivery.update(send_time: send_time)
				logger.error "MailChimp Webhook error: could not update send_time in this subscription_delivery record for campaign ID => #{id}; subscription_delivery => #{subscription_delivery.inspect}"
			end
		end
	end
	
	def archive_campaign(campaign_info)
		id = campaign_info['id']
		
		if folder_id_skip_list.include?(campaign_info['settings']['folder_id'])
			logger.info "MailChimp Webhook: Newsletter campaign is in skip list. Not archiving. ID => #{id}; title => \"#{campaign_info['settings']['title']}\""
			return
		end
		
		newsletter = Newsletter.find_by_cid(id) || Newsletter.new
		
		if newsletter.new_record?
			campaign_content = retrieve_campaign_content(id)
			if campaign_content.present?
				newsletter.cid = id
				newsletter.list_id = campaign_info['recipients']['list_id']
				newsletter.send_time = campaign_info['send_time'].to_date
				newsletter.title = campaign_info['settings']['title']
				newsletter.subject = campaign_info['settings']['subject_line']
				newsletter.archive_url = campaign_info['archive_url']
				newsletter.content = campaign_content
				if !newsletter.save
					logger.error "MailChimp Webhook error: save failed for campaign ID => #{id}; errors => #{newsletter.errors.messages}; campaign_info => #{campaign_info}; campaign_content starts with \"#{campaign_content.try :slice, 0, 20}\""
				end
			else
				logger.error "MailChimp Webhook error: could not retrieve content for campaign ID => #{id}; campaign_info => #{campaign_info}; campaign_content starts with \"#{campaign_content.try :slice, 0, 20}\""
			end
		else
			logger.error "MailChimp Webhook error: Newsletter archive record already exists for campaign ID => #{id}.  Ignoring this webhook event."
		end
	end

	def retrieve_campaign_info(id)
		begin
			info = Gibbon::Request.campaigns(id).retrieve
		rescue Gibbon::MailChimpError => e
			logger.error "Error while retrieving MailChimp archive list: #{e.title}; #{e.detail}; status: #{e.status_code}; campaign ID: #{id}"
		ensure
			return info || {}
		end
	end

	def retrieve_campaign_content(id)
		begin
			content = Gibbon::Request.campaigns(id).content.retrieve
			html = content.try :[], 'html'
		rescue Gibbon::MailChimpError => e
			logger.error "Error while retrieving MailChimp newsletter content: #{e.title}; #{e.detail}; status: #{e.status_code}; campaign ID: #{id}"
		ensure
			return html
		end
	end
end
