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
				logger.info "MailChimp Webhook: unexpected incoming notification. Params: #{params}" if logger
			end
		else
			logger.info "MailChimp Webhook: invalid incoming notification. Params: #{params}" if logger
		end
		render :nothing => true
	end
	
	private

	def on_unsubscribe(data)
		incoming_list_id = data['list_id']
		subscriber_email = data['email']
		list_name = Rails.configuration.mailchimp_list_id.key(incoming_list_id)

		if !User.mailing_list_name_valid?(list_name)
			logger.info "MailChimp Webhook unsubscribe verification failed: incoming_list_id \'#{incoming_list_id}\' is not valid. List name: #{list_name}." if logger
			return
		end
		if User.exists?(email: subscriber_email)
			user = User.find_by_email(subscriber_email)
		else
			logger.error "MailChimp Webhook unsubscribe verification failed: user with email #{subscriber_email} is not found." if logger
			return
		end
		if data['reason'] == 'abuse'
			logger.info "MailChimp Webhook: user \'id##{user.id}\' reported abuse." if logger
		end
		
		emails = [{email: user.email, leid: user.leids[list_name]}]
		begin
			gb = Gibbon::API.new
			r = gb.lists.member_info id: incoming_list_id, emails: emails
			if r.present?
				user_unsubscribed = (r['success_count'] == 1 && r['data'][0]['status'] == 'unsubscribed')
				user_deleted = r['error_count'] == 1
				if user_unsubscribed || user_deleted
					user.process_unsubscribe_event(list_name)
				else
					logger.info "MailChimp Webhook unsubscribe verification failed. MailChimp response: #{r}" if logger
				end
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
					logger.info "MailChimp Webhook: campaign save failed." if logger
				end
			end
		end
	end

	def retrieve_campaign_info(id)
		gb = Gibbon::API.new
		begin
			filters = { campaign_id: id, status: 'sent' }
			r = gb.campaigns.list filters: filters
			info = r.try(:[], 'data').try(:first) unless r.blank?
		rescue Exception => e
			logger.info "Error while retrieving MailChimp archive list: #{e.message}" if logger
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
			logger.info "Error while retrieving MailChimp newsletter content: #{e.message}" if logger
		ensure
			return html
		end
	end
end
