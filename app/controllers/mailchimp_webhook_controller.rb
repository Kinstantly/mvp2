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
			when 'subscribe'
				on_subscribe data
			when 'unsubscribe'
				on_unsubscribe data
			when 'campaign'
				on_campaign_sent data
			when 'upemail'
				on_upemail data
			else
				logger.error "MailChimp Webhook error: unexpected incoming notification. Params: #{params}" if logger
			end
		else
			logger.error "MailChimp Webhook error: invalid incoming notification. Params: #{params}" if logger
		end
		render :nothing => true
	end
	
	private

	def on_subscribe(data)
		list_id = data['list_id']
		subscriber_email = data['email']
		
		unless valid_list_id?(list_id) && valid_email?(subscriber_email, 'subscriber email')
			return
		end
		
		begin
			member = Gibbon::Request.lists(list_id).members(email_md5_hash(subscriber_email)).retrieve
			
			if member.present? && member['status'] == 'subscribed'
				#  create or update Subscription record
				create_or_update_subscription member

				#  update User record if it exists
				update_user_if_any member
			else
				logger.error "MailChimp Webhook subscribe error: Request for subscriber data on MailChimp returned nil or invalid subscriber status. Response => #{member.inspect}"
			end
		rescue Gibbon::MailChimpError => e
			logger.error "MailChimp Webhook error while processing 'subscribe' notification: #{e.title}; #{e.detail}; status: #{e.status_code}; email: #{subscriber_email}; list_id: #{list_id}"
		end
	end
	
	def create_or_update_subscription(member)
		subscription = Subscription.find_or_initialize_by({
			list_id: member['list_id'],
			unique_email_id: member['unique_email_id']
		})
		
		unless subscription.update({
			status: member['status'],
			subscriber_hash: member['id'],
			email: member['email_address'],
			fname: member['merge_fields']['FNAME'],
			lname: member['merge_fields']['LNAME'],
			birth1: member['merge_fields']['DUEBIRTH1'],
			birth2: member['merge_fields']['BIRTH2'],
			birth3: member['merge_fields']['BIRTH3'],
			birth4: member['merge_fields']['BIRTH4'],
			zip_code: member['merge_fields']['ZIPCODE'],
			postal_code: member['merge_fields']['POSTALCODE'],
			country: member['merge_fields']['COUNTRY'],
			subsource: (member['merge_fields']['SUBSOURCE'].presence || 'mailchimp_api')
		})
			logger.error "MailChimp Webhook subscribe error while creating or updating subscription record; errors => #{subscription.errors.full_messages.join '; '}; subscription => #{subscription.inspect}"
		end
	end
	
	def update_user_if_any(member)
		if user = User.find_by_email_ignore_case(member['email_address'])
			list_name = mailchimp_list_ids.key member['list_id']
			
			# Do not trigger a callback on the user model or we might create an infinite loop!
			unless user.update_columns({
				list_name => true,
				User.leid_attr_name(list_name) => member['unique_email_id']
			})
				logger.error "MailChimp Webhook subscribe error while updating user record; errors => #{user.errors.full_messages.join '; '}; user email => #{user.email}"
			end
		end
	end

	def on_unsubscribe(data)
		incoming_list_id = data['list_id']
		subscriber_email = data['email']
		
		unless valid_list_id?(incoming_list_id) && valid_email?(subscriber_email, 'subscriber email')
			return
		end
		
		list_name = mailchimp_list_ids.key(incoming_list_id)
		
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
					
					update_subscription_status list_id: r['list_id'], unique_email_id: r['unique_email_id'], status: r['status']
					
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
				
				update_subscription_status list_id: incoming_list_id, email: subscriber_email, status: 'deleted'
				
				AdminMailer.newsletter_subscriber_delete_alert(list_name, subscriber_email).deliver_now
				# AdminMailer.newsletter_unsubscribe_alert(list_name, subscriber_email).deliver_now
				logger.info "MailChimp Webhook unsubscribe: No subscription record for list_name => #{list_name}, email => #{subscriber_email}; was most likely deleted rather than unsubscribed" if logger
			else
				logger.error "MailChimp Webhook error while processing notification: #{e.title}; #{e.detail}; status: #{e.status_code}; email: #{subscriber_email}" if logger
			end
		end
	end
	
	def update_subscription_status(member)
		list_id = member[:list_id]
		unique_email_id = member[:unique_email_id]
		email = member[:email]
		status = member[:status]
		
		query = if unique_email_id.present?
			Subscription.where(list_id: list_id, unique_email_id: unique_email_id)
		elsif email.present?
			Subscription.where(list_id: list_id).where('LOWER(email) = ?', email.downcase)
		else
			logger.error "MailChimp Webhook error: not enough information to update subscription status for #{member}"
		end
		
		query.find_each do |subscription|
			unless subscription.update status: status
				logger.error "MailChimp Webhook error: could not update subscription status for #{member}; subscription => #{subscription.inspect}"
			end
		end
	end
	
	def on_upemail(data)
		list_id = data['list_id']
		new_unique_email_id = data['new_id']
		new_email = data['new_email']
		old_email = data['old_email']
		
		unless valid_list_id?(list_id) &&
			valid_id?(new_unique_email_id, 'new unique_email_id') &&
			valid_email?(new_email, 'new email address') &&
			valid_email?(old_email, 'old email address')
			return
		end
		
		old_unique_email_id = nil # Will be used to query user accounts below.
		
		# Update subscription with new email address, new unique_email_id, and new subscriber_hash.
		query = Subscription.where(list_id: list_id).where('LOWER(email) = ?', old_email.downcase)
		query.find_each do |subscription|
			old_unique_email_id = subscription.unique_email_id
			
			unless subscription.update({
				email: new_email,
				subscriber_hash: email_md5_hash(new_email),
				unique_email_id: new_unique_email_id
			})
				logger.error "MailChimp Webhook error on 'upemail' event: could not update subscription for #{old_email}; new email => #{new_email}; new unique_email_id => #{new_unique_email_id}; subscription => #{subscription.inspect}"
			end
		end
		
		# Update user account, if any, with the new unique_email_id.
		# Find account with old_email or by leid (if subscriber email was changed in the past).
		leid_attr_name = User.leid_attr_name mailchimp_list_ids.key(list_id)
		query = if old_unique_email_id.present?
			User.where("LOWER(email) = ? OR #{leid_attr_name} = ?", old_email.downcase, old_unique_email_id)
		else
			User.where("LOWER(email) = ?", old_email.downcase)
		end
		query.find_each do |user|
			unless user.update(leid_attr_name => new_unique_email_id)
				logger.error "MailChimp Webhook error on 'upemail' event: could not update user account for #{old_email}; old unique_email_id => #{old_unique_email_id}; new unique_email_id => #{new_unique_email_id}"
			end
		end
	end
	
	def incoming_data_valid?(params)
		params[EVENT_KEY].present? && params[DATA_KEY].present?
	end

	def token_valid?(params)
		params['token'].present? && params['token'] == SECURITY_TOKEN
	end
	
	def valid_id?(id, name)
		if id.present? and id =~ /\A\w+\z/
			true
		else
			logger.error "MailChimp Webhook error: #{name} is not valid; #{name} => \"#{id}\""
			false
		end
	end
	
	def valid_email?(email, name)
		if email.present? and email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
			true
		else
			logger.error "MailChimp Webhook error: #{name} is not valid; #{name} => \"#{email}\""
			false
		end
	end
	
	def valid_list_id?(list_id)
		return false unless valid_id?(list_id, 'list ID')
		
		list_name = mailchimp_list_ids.key(list_id)

		if User.mailing_list_name_valid?(list_name)
			true
		else
			logger.error "MailChimp Webhook error: list name \"#{list_name}\" is not valid; list_id => \"#{list_id}\""
			false
		end
	end
	
	def folder_id_skip_list
		[
			mailchimp_folder_ids[:parent_newsletters_campaigns],
			mailchimp_folder_ids[:parent_newsletters_source_campaigns]
		]
	end

	def on_campaign_sent(data)
		id = data['id']
		return unless valid_id?(id, 'campaign ID')
		
		campaign_info = retrieve_campaign_info(id)
		if campaign_info.blank?
			logger.error "MailChimp Webhook error: could not retrieve info for campaign ID => #{id}; campaign_info => #{campaign_info}"
			return
		end
		
		if campaign_info['status'] != 'sent'
			logger.info "MailChimp Webhook: Newsletter campaign has not been sent. Not marking as sent. Not archiving. ID => #{id}; status => \"#{campaign_info['status']}\"; title => \"#{campaign_info['settings']['title']}\""
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
