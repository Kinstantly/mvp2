namespace :kinstantly do
	desc 'Ensure that providers are only subscribed to provider mailing lists and that clients are only subscribed to parent mailing lists.'
	task role_specific_email_subscriptions: :environment do
		dry_run = ENV['dry_run'].present?
		
		puts "email\t\trole\tparent_marketing_emails\tparent_newsletters\tprovider_marketing_emails\tprovider_newsletters"
		
		User.where("parent_marketing_emails = 't' OR parent_newsletters = 't' OR provider_marketing_emails = 't' OR provider_newsletters = 't'").each do |user|
			if user.is_provider?
				user.parent_marketing_emails = false
				user.parent_newsletters = false
			else
				user.provider_marketing_emails = false
				user.provider_newsletters = false
			end
			user.save unless dry_run
			
			puts "#{user.email}\t#{user.is_provider? ? 'provider' : 'client  '}\t#{user.parent_marketing_emails}\t#{user.parent_newsletters}\t#{user.provider_marketing_emails}\t#{user.provider_newsletters}"
		end
	end
end
