# This file is required by features/support/env.rb for Cucumber scenarios.
# So make sure everything in here is compatible with Cucumber using RSpec mocks.

include NewsletterSubscriptionHelpers

def set_up_gibbon_mocks
	set_up_gibbon_lists_api_mock
	set_up_gibbon_campaigns_api_mock
end

def set_up_gibbon_lists_api_mock
	Struct.new 'ListAPI' unless defined? Struct::ListAPI
	Struct.new 'MemberAPI' unless defined? Struct::MemberAPI
	
	@mailchimp_lists = {}
	@mailchimp_apis = {}
	
	# return API for the list with the specified ID
	allow(Gibbon::Request).to receive(:lists) do |list_id|
		if @mailchimp_apis[list_id]
			# called more than once for the same list; return the existing list_api
			next @mailchimp_apis[list_id][:list_api]
		end
		
		list_api = double('Struct::ListAPI').as_null_object
		@mailchimp_apis[list_id] = { list_api: list_api }
		
		# return API for the list member with the specified email hash
		# or for all list members if no email hash specified
		allow(list_api).to receive(:members) do |email_hash|
			if @mailchimp_apis[list_id][email_hash]
				# called more than once for the same subscription; return the existing member_api
				next @mailchimp_apis[list_id][email_hash]
			end
			
			member_api = double('Struct::MemberAPI').as_null_object
			@mailchimp_apis[list_id][email_hash] = member_api
			
			# if the subscription exists, update it, otherwise create it
			allow(member_api).to receive(:upsert) do |arg|
				@mailchimp_lists[list_id] ||= {}
				@mailchimp_lists[list_id][email_hash] ||= {}
				
				body = @mailchimp_lists[list_id][email_hash]
				body.merge! arg[:body]
				body[:id] = email_hash
				body[:unique_email_id] = email_hash # fake it
				body[:list_id] = list_id
				
				log_member_api_info(:upsert, list_id, email_hash, body)
				
				list_member_api_response body
			end
			
			# update an existing subscription
			allow(member_api).to receive(:update) do |arg|
				if @mailchimp_lists[list_id].try(:[], email_hash).blank?
					raise list_member_not_found_exception(list_id, email_hash)
				end
				
				body = @mailchimp_lists[list_id][email_hash]
				body.merge! arg[:body]
				
				if body[:email_address].present? and 
					(new_email_hash = email_md5_hash(body[:email_address])) != email_hash
					# the email address was updated; move to new hash location
					body[:id] = new_email_hash
					body[:unique_email_id] = new_email_hash # fake it
					@mailchimp_lists[list_id][new_email_hash] = body
					@mailchimp_lists[list_id][email_hash] = nil
				end
				
				log_member_api_info(:update, list_id, email_hash, body)
				
				list_member_api_response body
			end
			
			# retrieve an existing subscription or the whole list
			allow(member_api).to receive(:retrieve) do |arg|
				list = @mailchimp_lists[list_id] || {}
				
				if email_hash # Retrieve a single member.
					if list[email_hash].blank?
						raise list_member_not_found_exception(list_id, email_hash)
					end
				
					body = list[email_hash]
				
					log_member_api_info(:retrieve, list_id, email_hash, body)
				
					list_member_api_response body
				else # Retrieve a collection of members.
					if arg && arg[:params] # Parse optional parameters.
						offset = arg[:params][:offset].presence.try(:to_i)
						count = arg[:params][:count].presence.try(:to_i)
					end
					# Default values of MailChimp API.
					offset ||= 0
					count ||= 10
					
					member_keys = list.keys.sort # Sort so that offset calls will work.
					member_keys_slice = member_keys[offset, count] || []
					
					members = member_keys_slice.map do |email_hash|
						body = list[email_hash]
						
						log_member_api_info(:retrieve, list_id, email_hash, body)
						
						list_member_api_response body
					end
					
					{'members' => members}
				end
			end
			
			# delete an existing subscription
			allow(member_api).to receive(:delete) do
				list = @mailchimp_lists[list_id] || {}
				
				if list[email_hash].blank?
					raise list_member_not_found_exception(list_id, email_hash)
				end
				
				log_member_api_info(:delete, list_id, email_hash, nil)
				
				list.delete email_hash
				nil
			end
			
			member_api
		end
		
		list_api
	end
end

def list_member_api_response(body)
	# return a copy of merge_fields and stringify the keys
	merge_fields = {}
	body[:merge_fields].keys.each do |key|
		merge_fields[key.to_s] = normalize_response_field_value key, body[:merge_fields][key]
	end if body[:merge_fields]
	
	{
		'email_address' => body[:email_address],
		'status' => body[:status],
		'id' => body[:id],
		'unique_email_id' => body[:unique_email_id],
		'list_id' => body[:list_id],
		'merge_fields' => merge_fields
	}
end

def normalize_response_field_value(name, value)
	case name.to_s
	when 'DUEBIRTH1', /\ABIRTH\d+\z/
		date = value.split '/'
		sprintf '%d-%02d-%02d', date[2], date[0], date[1]
	else
		value
	end
end

def list_not_found_exception(list_id)
	Gibbon::MailChimpError.new('List not found', title: 'List not found', detail: "list_id => #{list_id}", status_code: 404)
end

def list_member_not_found_exception(list_id, email_hash)
	Gibbon::MailChimpError.new('List member not found', title: 'List member not found', detail: "list_id => #{list_id}; email_hash => #{email_hash}", status_code: 404)
end

def log_member_api_info(method, list_id, email_hash, body)
	if ENV['DISPLAY_TEST_LOG'].present?
		puts "method => #{method}; list_id => #{list_id}; email_hash => #{email_hash}; body => #{body}"
	end
end

def set_up_gibbon_campaigns_api_mock
	Struct.new 'SingleCampaignAPI' unless defined? Struct::SingleCampaignAPI
	single_campaign_api = double('Struct::SingleCampaignAPI').as_null_object
	
	allow(Gibbon::Request).to receive(:campaigns).with(kind_of(String)).and_return(single_campaign_api)
	
	# retrieve a single campaign
	allow(single_campaign_api).to receive(:retrieve).and_return(
		{
			'id' => 'c123',
			'status' => 'sent',
			'send_time' => '2015-07-17T10:13:04+00:00',
			'archive_url' => 'http://example.com',
			'recipients' => {
				'list_id' => 'abc123'
			},
			'settings' => {
				'title' => 'Latest parenting news',
				'subject_line' => 'THIS WEEKEND: sport events'
			}
		}
	)
	
	# retrieve campaign content
	Struct.new 'SingleCampaignContentAPI' unless defined? Struct::SingleCampaignContentAPI
	single_campaign_content_api = double('Struct::SingleCampaignContentAPI').as_null_object
	
	allow(single_campaign_api).to receive(:content).and_return(single_campaign_content_api)
	
	allow(single_campaign_content_api).to receive(:retrieve).and_return(
		{
			'plain_text' => 'THIS WEEKEND: sport events.',
			'html' => '<!DOCTYPE html><html><head></head><body>THIS WEEKEND: sport events.</body></html>'
		}
	)
end

def mailing_lists
	['parent_newsletters', 'provider_newsletters']
end

# Make sure all of the test mailing lists are empty.
def empty_mailing_lists
	begin
		mailing_lists.each do |list_name|
			list_id = Rails.configuration.mailing_lists[:mailchimp_list_ids][list_name.to_sym]
			r = Gibbon::Request.lists(list_id).members.retrieve params: {fields: 'members.email_address'}
			r['members'].try(:each) do |member|
				email = member['email_address']
				Gibbon::Request.lists(list_id).members(email_md5_hash(email)).delete
			end
		end
	rescue Gibbon::MailChimpError => e
		puts "MailChimp error while deleting: #{e.title}; #{e.detail}; status: #{e.status_code}"
	end
end

# Get info for a particular member of the specified list.
def member_of_mailing_list(email, list_name)
	begin
		list_id = Rails.configuration.mailing_lists[:mailchimp_list_ids][list_name.to_sym]
		Gibbon::Request.lists(list_id).members(email_md5_hash(email)).retrieve
	rescue Gibbon::MailChimpError => e
		puts "MailChimp error while retrieving member info: #{e.title}; #{e.detail}; status: #{e.status_code}; email: #{email}; list: #{list_name}"
	end
end

def campaign_folders
	[:parent_newsletters_source_campaigns]
end

def empty_campaign_folders
	begin
		campaign_folders.each do |folder|
			folder_id = Rails.configuration.mailing_lists[:mailchimp_folder_ids][folder.to_sym]
			r = Gibbon::Request.campaigns.retrieve params: {folder_id: folder_id}
			r['campaigns'].try(:each) do |campaign|
				Gibbon::Request.campaigns(campaign['id']).delete
			end
		end
	rescue Gibbon::MailChimpError => e
		puts "MailChimp error while deleting: #{e.title}; #{e.detail}; status: #{e.status_code}"
	end
end
