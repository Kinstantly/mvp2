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
		list_name = Rails.configuration.mailchimp_list_id.key(incoming_list_id)

		if !User.mailing_list_name_valid?(list_name)
			logger.error "MailChimp Webhook unsubscribe verification error: incoming_list_id \'#{incoming_list_id}\' is not valid. List name: #{list_name}." if logger
			return
		end
		if data['reason'] == 'abuse'
			logger.info "MailChimp Webhook: user reported abuse: email => #{subscriber_email}" if logger
		end
		
		emails = [{email: subscriber_email}]
		begin
			gb = Gibbon::API.new
			r = gb.lists.member_info id: incoming_list_id, emails: emails
			if r.present?
				user_unsubscribed = (r['success_count'] == 1 && r['data'][0]['status'] == 'unsubscribed')
				user_deleted = r['error_count'] == 1
				if user_unsubscribed || user_deleted
					if User.exists?(email: subscriber_email)
						user = User.find_by_email(subscriber_email)
						user.process_unsubscribe_event(list_name)
					end
					AdminMailer.newsletter_unsubscribe_alert(list_name, subscriber_email).deliver
				else
					logger.error "MailChimp Webhook unsubscribe verification error. MailChimp response: #{r}" if logger
				end
			else
				logger.info "MailChimp Webhook unsubscribe: No member_info for list_name => #{list_name}, email => #{subscriber_email}" if logger
			end
		rescue Gibbon::MailChimpError => e
			logger.error "MailChimp Webhook error while processing notification: #{e.message}, error code: #{e.code}." if logger
		end
	end
	
	def incoming_data_valid?(params)
		params[EVENT_KEY].present? && params[DATA_KEY].present?
	end

	def token_valid?(params)
		params['token'].present? && params['token'] == SECURITY_TOKEN
	end

	def on_campaign_sent(data)
		id = data['id']
		newsletter = Newsletter.find_by_cid(id) || Newsletter.new
		if newsletter.new_record?
			campaign_info = retrieve_campaign_info(id)
			campaign_content = retrieve_campaign_content(id)
			if campaign_info.present? && campaign_content.present?
				newsletter.cid = id
				newsletter.list_id = campaign_info['list_id']
				newsletter.send_time = campaign_info['send_time'].to_date
				newsletter.title = campaign_info['title']
				newsletter.subject = campaign_info['subject']
				newsletter.archive_url = campaign_info['archive_url']
				newsletter.content = campaign_content
				if !newsletter.save
					logger.error "MailChimp Webhook error: campaign save failed." if logger
				end
			else
				logger.error "MailChimp Webhook error: could not retrieve info or content for campaign ID => #{id}" if logger
			end
		else
			logger.error "MailChimp Webhook error: Newsletter campaign record already exists for campaign ID => #{id}.  Ignoring this webhook event." if logger
		end
	end

	def retrieve_campaign_info(id)
		gb = Gibbon::API.new
		begin
			filters = { campaign_id: id }
			r = gb.campaigns.list filters: filters
			info = r.try(:[], 'data').try(:first) unless r.blank?
		rescue Exception => e
			logger.error "Error while retrieving MailChimp archive list: #{e.message}" if logger
		ensure
			return info || []
		end
	end

	def retrieve_campaign_content(id)
		gb = Gibbon::API.new
		begin
			r = gb.campaigns.content cid: id
			html = r.try(:[], 'html') unless r.blank?
		rescue Exception => e
			logger.error "Error while retrieving MailChimp newsletter content: #{e.message}" if logger
		ensure
			return html
		end
	end
end
