class MailchimpListImporter
	
	include SiteConfigurationHelpers
	
	attr_reader :params, :errors, :total_imported, :total_created, :total_updated
	
	def initialize(params)
		@params = params
		@errors = []
		@total_imported = @total_created = @total_updated = 0
		@successful = true
	end
	
	def call
		if params[:list].empty?
			@errors << 'List must be specified.'
			return (@successful = false)
		end
		
		list_id = mailchimp_list_ids[params[:list]]
		limit = params[:limit]
		
		fields = 'members.status,members.list_id,members.id,members.unique_email_id,members.email_address,members.merge_fields'
		batch_size = params[:batch_size] || 50
		offset, response = 0, nil
		while response.blank? || response['members'].size > 0 do
			response = Gibbon::Request.lists(list_id).members.retrieve(params: {
				count: "#{batch_size}",
				offset: "#{offset}",
				fields: fields
			})
			
			response['members'].each do |member|
				create_or_update member
			end
			
			offset += batch_size
			break if limit && @total_imported >= limit
		end
	end
	
	def successful?
		@successful
	end
	
	private
	
	def create_or_update(member)
		puts "#{member['email_address']}\t#{member['merge_fields']['DUEBIRTH1']}" if params[:verbose].present?
		
		sub = Subscription.find_or_initialize_by email: member['email_address']
		is_new = sub.new_record?
		
		success = sub.update({
			subscribed:      (member['status'] == 'subscribed'),
			status:          member['status'],
			list_id:         member['list_id'],
			subscriber_hash: member['id'],
			unique_email_id: member['unique_email_id'],
			fname:           member['merge_fields']['FNAME'],
			lname:           member['merge_fields']['LNAME'],
			birth1:          member['merge_fields']['DUEBIRTH1'],
			birth2:          member['merge_fields']['BIRTH2'],
			birth3:          member['merge_fields']['BIRTH3'],
			birth4:          member['merge_fields']['BIRTH4'],
			zip_code:        member['merge_fields']['ZIPCODE'],
			postal_code:     member['merge_fields']['POSTALCODE'],
			country:         member['merge_fields']['COUNTRY'],
			subsource:       member['merge_fields']['SUBSOURCE']
		})
		
		if success
			@total_imported += 1
			if is_new
				@total_created += 1
			elsif sub.previous_changes.present?
				@total_updated += 1
			end
		else
			@errors << "Failed to save #{member['email_address']}: #{sub.errors.full_messages.join(', ')}"
		end
		
		success
	end
end
