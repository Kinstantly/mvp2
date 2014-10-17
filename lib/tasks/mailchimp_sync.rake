namespace :mailchimp do
	desc 'Find users who opt-in for emails and send the list to MailChimp in a single batch.'
	task batch_subscribe: [:environment] do
		list_id = Rails.configuration.mailchimp_list_id
		subscribers = User.where "parent_marketing_emails = true OR parent_newsletters = true OR provider_marketing_emails = true OR provider_newsletters = true"
		batch = []
		puts "Starting MailChimp batch-subscribe to the list# #{list_id}. Batch size: #{subscribers.size}"
		subscribers.each do |subscriber|
			next if !(subscriber.client? || subscriber.expert?)
			merge_vars = {groupings: []}
			first_name = subscriber.username.presence || subscriber.email.presence
			last_name  = ''
			if subscriber.client?
				groups = []
				groups << 'marketing_emails' if subscriber.parent_marketing_emails
				groups << 'newsletters' if subscriber.parent_newsletters
				if groups.any?
					merge_vars[:groupings] << {name: 'parent', groups: groups}
				end
			end
			if subscriber.expert?
				first_name = subscriber.profile.first_name if subscriber.profile.first_name.present?
				last_name  = subscriber.profile.last_name if subscriber.profile.last_name.present?
				groups = []
				groups << 'marketing_emails' if subscriber.provider_marketing_emails
				groups << 'newsletters' if subscriber.provider_newsletters
				if groups.any?
					merge_vars[:groupings] << {name: 'provider', groups: groups}
				end
			end
			merge_vars[:FNAME] = first_name 
			merge_vars[:LNAME] = last_name
			email_struct = {email: subscriber.email, 
							euid: subscriber.subscriber_euid, 
							leid: subscriber.subscriber_leid}
			merge_vars['new-email'] = subscriber.email

			if merge_vars[:groupings].any?
				batch << {email: email_struct, merge_vars: merge_vars}
			end
		end
		begin
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
		rescue Gibbon::MailChimpError => e
			puts "MailChimp sync failed: #{e.message}, error code: #{e.code}"
		end
	end
end
