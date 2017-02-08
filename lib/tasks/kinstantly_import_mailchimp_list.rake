namespace :kinstantly_import_mailchimp_list do
	
	desc 'Import KidNotes list members into local subscription records. If a member is already in a local record, update the subscription, otherwise create a new one. You can specify an optional batch size and a limit to the number of members to import (rounded up to the next batch increment), e.g., "bin/rake kinstantly_import_mailchimp_list:kidnotes batch_size=5 limit=20"'
	task kidnotes: :environment do
		params = {
			list: :parent_newsletters, # Import KidNotes list
			batch_size: ENV['batch_size'].try(:to_i),
			limit: ENV['limit'].try(:to_i),
			verbose: ENV['verbose']
		}
		list_importer = MailchimpListImporter.new(params)
		list_importer.call
		puts "KidNotes import #{list_importer.successful? ? 'succeeded' : 'failed'}."
		puts "Total imported: #{list_importer.total_imported}"
		puts "Total created: #{list_importer.total_created}"
		puts "Total updated: #{list_importer.total_updated}"
		if list_importer.errors.present?
			puts "Errors:"
			list_importer.errors.each { |error| puts "  #{error}" }
		end
	end
	
end
