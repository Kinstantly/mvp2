namespace :mailchimp do
	desc 'Find users who opt-in for emails and send the list to MailChimp in a single batch.'
	task batch_subscribe: [:environment] do
		list_names = [:parent_newsletters_stage1, :parent_newsletters_stage2, :parent_newsletters_stage3, :provider_newsletters]
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
					when 'SUBSCRIPTIONLISAGEST0-4'
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
	
	def build_batch(list_name)
		subscribers = User.where(list_name => true)
		batch = []
		puts "Building MailChimp batch-subscribe for #{list_name} list. Batch size: #{subscribers.size}"
		subscribers.each do |subscriber|
			next if !(subscriber.client? || subscriber.expert?) or !subscriber.confirmed? or subscriber.contact_is_blocked?
			
			first_name = subscriber.username.presence || subscriber.email.presence
			last_name  = ''
			if subscriber.expert?
				first_name = subscriber.profile.first_name if subscriber.profile.first_name.present?
				last_name  = subscriber.profile.last_name if subscriber.profile.last_name.present?
			end
			merge_vars = { FNAME: first_name, LNAME: last_name }
			
			email_struct = { email: subscriber.email }
			subscriber_leid = subscriber.leids[list_name]
			
			if subscriber_leid
				merge_vars['new-email'] = subscriber.email
				email_struct['leid'] = subscriber_leid
			end
			puts "Adding user to the batch: #{email_struct}"
			batch << { email: email_struct, merge_vars: merge_vars }
		end
		batch
	end

	def updated_leids(list_name, data)
		data.each do |new_subscriber_data|
			email = new_subscriber_data['email']
			leid = new_subscriber_data['leid']
			if User.exists?(email: email)
				user = User.find_by_email(email)
				user.process_subscribe_event(list_name, leid)
			end
		end
	end

	def batch_subscribe_to_list(list_name)
		list_id = Rails.configuration.mailchimp_list_id[list_name]
		return if list_id.blank?
		batch = build_batch(list_name)
		begin
			puts "Sending batch-subscribe request to MailChimp..."
			gb = Gibbon::API.new
			r = gb.lists.batch_subscribe id: list_id, batch: batch, double_optin: false, update_existing: true
			#puts r
			puts "Successfully added: #{r['add_count']}."
			puts "Updated: #{r['update_count']}."
			puts "Failed to add: #{r['error_count']}."
			if(r['errors'].present?)
				r['errors'].each do |e|
					puts "Error details:"
					puts "#{e['email']['email']}"
					puts "----error message: #{e['error']}"
					puts "----error code: #{e['code']}"
				end
			end
			updated_leids(list_name, r['adds'] + r['updates'])
			puts "---------------------------------"
		rescue Gibbon::MailChimpError => e
			puts "MailChimp sync failed: #{e.message}, error code: #{e.code}"
		end
	end
end
