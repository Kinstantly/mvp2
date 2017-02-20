namespace :kinstantly_import_source_campaigns do
	
	desc 'Import KidNotes source campaigns from MailChimp into local SubscriptionStage records. The source campaigns are found in the stage-based source-campaign folder. If a campaign is already specified in a local SubscriptionStage record, update the record, otherwise create a new one. You can specify an optional batch size and a limit to the number of source campaigns to import (rounded up to the next batch increment), e.g., "bin/rake kinstantly_import_source_campaigns:kidnotes batch_size=5 limit=20"'
	task kidnotes: :environment do
		params = {
			list: :parent_newsletters, # Import source campaigns for KidNotes
			folder: :parent_newsletters_source_campaigns, # MailChimp folder with source campaigns
			batch_size: ENV['batch_size'].try(:to_i),
			limit: ENV['limit'].try(:to_i),
			verbose: ENV['verbose']
		}
		stage_importer = SubscriptionStageImporter.new(params)
		stage_importer.call
		puts "Import of KidNotes source campaigns #{stage_importer.successful? ? 'succeeded' : 'failed'}."
		puts "Total imported: #{stage_importer.total_imported}"
		puts "Total created: #{stage_importer.total_created}"
		puts "Total updated: #{stage_importer.total_updated}"
		if stage_importer.errors.present?
			puts "Errors:"
			stage_importer.errors.each { |error| puts "  #{error}" }
		end
	end
	
end
