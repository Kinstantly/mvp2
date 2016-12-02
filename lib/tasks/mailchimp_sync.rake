namespace :mailchimp do
	list_names = [
		:parent_marketing_emails,
		:parent_newsletters,
		:provider_marketing_emails,
		:provider_newsletters
	]
		
	desc 'Find users who opt-in for emails and send each list to MailChimp in a batch.'
	task batch_subscribe: [:environment] do
		list_names.each do |list_name|
			batch_subscribe_to_list(list_name)	
		end
	end

	task provider_newsletters_merge: [:environment] do
		providers_subscribed_to_marketing_emails = User.where(provider_marketing_emails: true)
		providers_subscribed_to_marketing_emails.each do |provider|
			unless provider.blank? || provider.provider_newsletters
				provider.provider_newsletters = true
				provider.save
			end
		end
		batch_subscribe_to_list(:provider_newsletters)
	end

	task parent_newsletters_merge: [:environment] do
		require 'csv'
		files = ['SUBSCRIPTIONLISTAGES0-4', 'SUBSCRIPTIONLISTAGES5-12', 'SUBSCRIPTIONLISTTEENS']   
		files.each do |file|	
			CSV.foreach("lib/data/#{file}.csv") do |row|
				if row[0] == 'REGISTERED AND SUBSCRIBED'
				  	parent = User.find_by_email(row[1])
				  	next if parent.blank?
				  	case file
					when 'SUBSCRIPTIONLISTAGES0-4'
						parent.parent_newsletters_stage1 = true
					when 'SUBSCRIPTIONLISTAGES5-12'
						parent.parent_newsletters_stage2 = true
					when 'SUBSCRIPTIONLISTTEENS'
						parent.parent_newsletters_stage3 = true
					end
				  	parent.save
			  end
			end
		end
		list_names = [:parent_newsletters_stage1, :parent_newsletters_stage2, :parent_newsletters_stage3]
		list_names.each do |list_name|
			batch_subscribe_to_list(list_name)	
		end
	end

	desc 'Retrieve remote archive and persist in DB.'	
	task newsletter_archive_import: [:environment] do
		newsletter_list = list_archive(true)
		newsletter_list.each do |newsletter_data|
			id = newsletter_data['id']
			newsletter = Newsletter.find_by_cid(id) || Newsletter.new
			if newsletter.new_record?			
				newsletter.cid = id
				newsletter.list_id = newsletter_data['recipients']['list_id']
				newsletter.send_time = newsletter_data['send_time'].to_date
				newsletter.title = newsletter_data['settings']['title']
				newsletter.subject = newsletter_data['settings']['subject_line']
				newsletter.archive_url = newsletter_data['archive_url']
				newsletter.content = newsletter_content(id)
				newsletter.save!
				puts "Newsletter '#{newsletter.cid}' has been saved."
			end
		end
	end
	
	def build_batch(list_name)
		subscribers = User.where(list_name => true)
		batch = []
		puts "Building MailChimp batch-subscribe for #{list_name} list. Batch size: #{subscribers.size}"
		subscribers.each do |subscriber|
			next if !(subscriber.client? || subscriber.expert?) or !subscriber.confirmed? or subscriber.contact_is_blocked? or subscriber.email.blank?
			
			merge_vars = { SUBSOURCE: 'directory_user_create_or_update' }
			if subscriber.expert?
				merge_vars[:FNAME] = subscriber.profile.first_name if subscriber.profile.first_name.present?
				merge_vars[:LNAME] = subscriber.profile.last_name if subscriber.profile.last_name.present?
			end
			
			puts "Adding user to the batch: #{subscriber.email}"
			batch << { email_address: subscriber.email, status: 'subscribed', merge_fields: merge_vars }
		end
		batch
	end

	def updated_leids(list_name, data)
		data.each do |subscriber_data|
			email = subscriber_data['email_address']
			leid = subscriber_data['unique_email_id']
			if User.exists?(email: email)
				user = User.find_by_email(email)
				user.process_subscribe_event(list_name, leid)
			end
		end
	end

	def batch_subscribe_to_list(list_name)
		list_id = Rails.configuration.mailing_lists[:mailchimp_list_ids][list_name]
		return if list_id.blank?
		batch = build_batch(list_name)
		begin
			puts "Sending batch-subscribe request to MailChimp..."
			
			r = Gibbon::Request.lists(list_id).create body: {
				members: batch,
				update_existing: true
			}
			
			puts "Successfully added: #{r['total_created']}."
			puts "Updated: #{r['total_updated']}."
			puts "Failed to add: #{r['error_count']}."
			if(r['errors'].present?)
				r['errors'].each do |e|
					puts "Error details for #{e['email_address']}: #{e['error']}"
				end
			end
			updated_leids(list_name, r['new_members'] + r['updated_members'])
			puts "---------------------------------"
		rescue Gibbon::MailChimpError => e
			puts "MailChimp sync error: #{e.title}; #{e.detail}; status: #{e.status_code}; errors: #{e.body['errors']}"
		end
	end

	def list_archive(include_old_editions)
		list_ids = [ Rails.configuration.mailing_lists[:mailchimp_list_ids][:parent_newsletters_stage1],
			Rails.configuration.mailing_lists[:mailchimp_list_ids][:parent_newsletters_stage2],
			Rails.configuration.mailing_lists[:mailchimp_list_ids][:parent_newsletters_stage3] ]
		# list_ids_filter = list_ids * ","
		if(include_old_editions)
			list_ids << Rails.configuration.mailing_lists[:mailchimp_list_ids][:parent_newsletters]
		end

		# gb = Gibbon::API.new
		begin
			# filters = { list_id: list_ids_filter, status: 'sent', exact: false }
			# r = gb.campaigns.list filters: filters, limit: 1000, sort_field: 'send_time'
			# data = r.try(:[], 'data') unless r.blank?
			
			data = []
			list_ids.each do |list_id|
				r = Gibbon::Request.campaigns.retrieve params: {
					list_id: list_id,
					status: 'sent',
					count: 1000,
					fields: 'campaigns.id,campaigns.archive_url,campaigns.send_time,campaigns.recipients.list_id,campaigns.settings.subject_line,campaigns.settings.title'
				}
				campaigns = r.try(:[], 'campaigns')
				data += campaigns if campaigns.present?
			end
			
			puts "Campaign IDs from archive: #{data.map {|campaign| campaign['id']}}"
		rescue Gibbon::MailChimpError => e
			puts "Error while retrieving MailChimp archive list: #{e.title}; #{e.detail}; status: #{e.status_code}; errors: #{e.body['errors']}"
		ensure
			return data || []
		end
	end

	def newsletter_content(id)
		begin
			content = Gibbon::Request.campaigns(id).content.retrieve
			html = content.try :[], 'html'
		rescue Gibbon::MailChimpError => e
			puts "Error while retrieving MailChimp newsletter content: #{e.title}; #{e.detail}; status: #{e.status_code}; errors: #{e.body['errors']}"
		ensure
			return html
		end
	end
end
