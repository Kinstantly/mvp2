class SubscriptionStageImporter
	
	include SiteConfigurationHelpers
	
	attr_reader :params, :errors, :total_imported, :total_created, :total_updated
	
	def initialize(params)
		@params = params
		@errors = []
		@total_imported = @total_created = @total_updated = 0
		@successful = true
	end
	
	def call
		list_id = mailchimp_list_ids[params[:list]]
		folder_id = mailchimp_folder_ids[params[:folder]]
		
		@errors << 'A valid list must be specified.' if list_id.blank?
		@errors << 'A valid folder must be specified.' if folder_id.blank?
		return (@successful = false) if @errors.present?
		
		limit = params[:limit]
		fields = 'campaigns.id,campaigns.settings.title'
		batch_size = params[:batch_size] || 50
		offset, response = 0, nil
		while response.blank? || response['campaigns'].size > 0 do
			response = Gibbon::Request.campaigns.retrieve(params: {
				count: "#{batch_size}",
				offset: "#{offset}",
				folder_id: folder_id,
				fields: fields
			})
			
			response['campaigns'].each do |campaign|
				create_or_update campaign, list_id
			end
			
			offset += batch_size
			break if limit && @total_imported >= limit
		end
		
		@successful
	end
	
	def successful?
		@successful
	end
	
	private
	
	def create_or_update(campaign, list_id)
		puts "#{campaign['id']}\t#{campaign['settings']['title']}" if params[:verbose].present?
		
		sub_stage = SubscriptionStage.find_or_initialize_by source_campaign_id: campaign['id']
		is_new = sub_stage.new_record?
		
		success = sub_stage.update({
			title:           campaign['settings']['title'],
			list_id:         list_id
		})
		
		if success
			@total_imported += 1
			if is_new
				@total_created += 1
			elsif sub_stage.previous_changes.present?
				@total_updated += 1
			end
		else
			@errors << "Failed to save subscription stage for source campaign #{campaign['id']}: #{sub_stage.errors.full_messages.join(', ')}"
		end
		
		success
	end
end
