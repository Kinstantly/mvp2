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
		system_list_id = Rails.configuration.mailchimp_list_id
		incoming_list_id = data['list_id']
		subscriber_email = data['email']

		if incoming_list_id != system_list_id
			logger.info "MailChimp Webhook unsubscribe verification failed: incoming_list_id \'#{incoming_list_id}\' does not match system_list_id \'#{system_list_id}\'." if logger
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

		emails = [{email: user.email, euid: user.subscriber_euid, leid: user.subscriber_leid}]
		begin
			gb = Gibbon::API.new
			r = gb.lists.member_info id: incoming_list_id, 
				emails: emails
			if r.present? && r['error_count'] == 1
				user.remove_email_subscriptions_locally
			else
				logger.info "MailChimp Webhook unsubscribe verification failed: requested user \'id##{user.id}\' has not been unsubscribed from the list \'id##{incoming_list_id}\'." if logger
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
end
