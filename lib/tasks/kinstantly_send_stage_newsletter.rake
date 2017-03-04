namespace :kinstantly_send_stage_newsletter do
	
	desc 'Schedule stage-based KidNotes campaigns for their next delivery. This is done by iterating through the SubscriptionStage records for the KidNotes mailing list. For each stage, if there are subscribers currently eligible for receipt of the stage\'s source campaign, the campaign is replicated into a scheduled/sent folder and scheduled for delivery to the selected subscribers. Each source campaign is found in the folder specified by the SubscriptionStage record. You can specify an optional batch size for retrieving records from the MailChimp API, e.g., "bin/rake kinstantly_send_stage_newsletter:kidnotes batch_size=25"'
	task kidnotes: :environment do
		params = {
			list: :parent_newsletters, # Schedule KidNotes campaigns for delivery
			folder: :parent_newsletters_campaigns, # MailChimp folder to hold scheduled and sent campaigns
			batch_size: ENV['batch_size']
		}
		sender = StageNewsletterSender.new(params)
		sender.call
		puts "Scheduling of KidNotes stage-based campaigns #{sender.successful? ? 'succeeded' : 'failed'}."
		puts "Total campaigns scheduled: #{sender.total_campaigns_scheduled}"
		puts "Total recipients: #{sender.total_recipients}"
		if sender.errors.present?
			puts "Errors:"
			sender.errors.each { |error| puts "  #{error}" }
		end
	end
	
end
