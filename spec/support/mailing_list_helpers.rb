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
	Struct.new 'SegmentAPI' unless defined? Struct::SegmentAPI
	Struct.new 'SegmentMembersAPI' unless defined? Struct::SegmentMembersAPI
	
	@mailchimp_lists = {}
	@mailchimp_list_apis = {}
	
	@mailchimp_list_segment_id = 0
	@mailchimp_list_segments = {}
	@mailchimp_list_segment_members = {}
	
	# return API for the list with the specified ID
	allow(Gibbon::Request).to receive(:lists) do |list_id|
		if @mailchimp_list_apis[list_id]
			# called more than once for the same list; return the existing list_api
			next @mailchimp_list_apis[list_id][:list_api]
		end
		
		list_api = double('Struct::ListAPI').as_null_object
		@mailchimp_list_apis[list_id] = {
			list_api: list_api,
			member_apis: {},
			segment_apis: {}
		}
		
		@mailchimp_lists[list_id] = {}
		@mailchimp_list_segments[list_id] = {}
		@mailchimp_list_segment_members[list_id] = {}
		
		# return API for the list member with the specified email hash
		# or for all list members if no email hash specified
		allow(list_api).to receive(:members) do |email_hash|
			if @mailchimp_list_apis[list_id][:member_apis][email_hash]
				# called more than once for the same subscription; return the existing member_api
				next @mailchimp_list_apis[list_id][:member_apis][email_hash]
			end
			
			member_api = double('Struct::MemberAPI').as_null_object
			@mailchimp_list_apis[list_id][:member_apis][email_hash] = member_api
			
			# create a new subscription
			allow(member_api).to receive(:create) do |arg|
				body = arg[:body]
				
				# Don't set email_hash. It would be confused with the parent block's argument in later invocations of other methods.
				member_id = email_md5_hash(body[:email_address])
				
				body[:id] = member_id
				body[:unique_email_id] = member_id # fake it
				body[:list_id] = list_id
				@mailchimp_lists[list_id][member_id] = body
				
				log_member_api_info(:create, list_id, member_id, body)
				
				list_member_api_response body
			end
			
			# if the subscription exists, update it, otherwise create it
			allow(member_api).to receive(:upsert) do |arg|
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
				if @mailchimp_lists[list_id][email_hash].blank?
					raise resource_not_found_exception
				end
				
				body = @mailchimp_lists[list_id][email_hash]
				body.merge! arg[:body]
				
				if body[:email_address].present? and 
					(new_email_hash = email_md5_hash(body[:email_address])) != email_hash
					# the email address was updated; move to new hash location
					body[:id] = new_email_hash
					body[:unique_email_id] = new_email_hash # fake it
					@mailchimp_lists[list_id][new_email_hash] = body
					@mailchimp_lists[list_id].delete(email_hash)
				end
				
				log_member_api_info(:update, list_id, email_hash, body)
				
				list_member_api_response body
			end
			
			# retrieve an existing subscription or the whole list
			allow(member_api).to receive(:retrieve) do |arg|
				list = @mailchimp_lists[list_id] || {}
				
				if email_hash # Retrieve a single member.
					if list[email_hash].blank?
						raise resource_not_found_exception
					end
				
					body = list[email_hash]
				
					log_member_api_info(:retrieve, list_id, email_hash, body)
				
					list_member_api_response body
				else # Retrieve a collection of members.
					if arg && arg[:params] # Parse optional parameters.
						offset = arg[:params][:offset].presence.try(:to_i)
						count = arg[:params][:count].presence.try(:to_i)
						unique_email_id = arg[:params][:unique_email_id].presence
					end
					# Default values of MailChimp API.
					offset ||= 0
					count ||= 10
					
					if unique_email_id
						# Create a NEW list of only members with unique_email_id.
						list = list.select do |key, body|
							body[:unique_email_id] == unique_email_id
						end
					end
					
					member_keys = list.keys.sort # Sort so that offset calls will work.
					member_keys_slice = member_keys[offset, count] || []
					
					members = member_keys_slice.map do |key|
						body = list[key]
						
						log_member_api_info(:retrieve, list_id, key, body)
						
						list_member_api_response body
					end
					
					{'members' => members}
				end
			end
			
			# delete an existing subscription
			allow(member_api).to receive(:delete) do
				list = @mailchimp_lists[list_id] || {}
				
				if list[email_hash].blank?
					raise resource_not_found_exception
				end
				
				log_member_api_info(:delete, list_id, email_hash, nil)
				
				list.delete email_hash
				nil
			end
			
			member_api
		end
		
		# return API for the list segment with the specified segment ID
		# or for all segments if no segment ID specified
		allow(list_api).to receive(:segments) do |segment_id|
			segment_id = segment_id.try :to_i # segment_id must be an integer
			if @mailchimp_list_apis[list_id][:segment_apis][segment_id]
				# called more than once for the same segment; return the existing segment_api
				next @mailchimp_list_apis[list_id][:segment_apis][segment_id]
			end
			
			segment_api = double('Struct::SegmentAPI').as_null_object
			@mailchimp_list_apis[list_id][:segment_apis][segment_id] = segment_api
			
			# create a new segment
			allow(segment_api).to receive(:create) do |arg|
				body = arg[:body]
				
				body[:id] = id = (@mailchimp_list_segment_id += 1) # Segment ID is an integer!
				body[:list_id] = list_id
				if (static_segment = body[:static_segment])
					verified_members = verify_segment_members static_segment, @mailchimp_lists[list_id]
					@mailchimp_list_segment_members[list_id][id] = verified_members
					body[:member_count] = verified_members.size
				end
				@mailchimp_list_segments[list_id][id] = body
				
				log_segment_api_info(:create, list_id, id, body)
				
				list_segment_api_response body
			end
			
			# API for members of this segment
			segment_members_api = double('Struct::SegmentMembersAPI').as_null_object
			allow(segment_api).to receive(:members).and_return(segment_members_api)
			
			# retrieve the members of this segment
			allow(segment_members_api).to receive(:retrieve) do |arg|
				if arg && arg[:params] # Parse optional parameters.
					offset = arg[:params][:offset].presence.try(:to_i)
					count = arg[:params][:count].presence.try(:to_i)
				end
				# Default values of MailChimp API.
				offset ||= 0
				count ||= 10
				
				emails = @mailchimp_list_segment_members[list_id][segment_id]
				raise resource_not_found_exception unless emails
				
				# Sort the emails so that offset calls will work.
				emails_slice = emails.sort[offset, (emails.size - offset)] || []
				found = 0
				
				member_list = emails_slice.map do |email|
					member = @mailchimp_lists[list_id][email_md5_hash(email)]
					if found < count && member
						found += 1
						list_member_api_response member
					else
						nil
					end
				end
				
				response = { 'members' => member_list.compact }
				
				log_segment_api_info('members.retrieve', list_id, segment_id, response)
				
				list_segment_api_response response
			end
			
			segment_api
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
		if value.present? && (date = value.split '/').size == 3
			sprintf '%d-%02d-%02d', date[2], date[0], date[1]
		else
			value.nil? ? '' : value
		end
	else
		value.nil? ? '' : value
	end
end

def list_segment_api_response(body)
	copy_hash_and_stringify_keys body
end

def verify_segment_members(segment, list)
	segment ||= []
	list ||= []
	verified_segment = segment.map do |email|
		member = list[email_md5_hash(email)]
		member && member[:status] == 'subscribed' ? email : nil
	end
	verified_segment.compact
end

def invalid_resource_exception(errors=[])
	Gibbon::MailChimpError.new('the server responded with status 400', title: 'Invalid Resource', detail: "The resource submitted could not be validated. For field-specific details, see the 'errors' array.", status_code: 400, body: {'status' => 400, 'errors' => errors})
end

def resource_not_found_exception
	Gibbon::MailChimpError.new('the server responded with status 404', title: 'Resource not found', detail: "The requested resource could not be found.", status_code: 404)
end

def log_member_api_info(method, list_id, email_hash, body)
	if ENV['DISPLAY_TEST_LOG'].present?
		puts "list members method => #{method}; list_id => #{list_id}; email_hash => #{email_hash}; body => #{body}"
	end
end

def log_segment_api_info(method, list_id, segment_id, response)
	if ENV['DISPLAY_TEST_LOG'].present?
		puts "list segments method => #{method}; list_id => #{list_id}; segment_id => #{segment_id}; response => #{response}"
	end
end

def log_campaign_api_info(method, campaign_id, response)
	if ENV['DISPLAY_TEST_LOG'].present?
		puts "campaigns method => #{method}; campaign_id => #{campaign_id}; response => #{response}"
	end
end

def set_up_gibbon_campaigns_api_mock
	Struct.new 'CampaignAPI' unless defined? Struct::CampaignAPI
	
	@mailchimp_campaign_id = 0
	@mailchimp_campaigns = {}
	@mailchimp_campaign_apis = {}
	
	allow(Gibbon::Request).to receive(:campaigns) do |campaign_id|
		# campaign_id is nil if referencing multiple campaigns
		
		if @mailchimp_campaign_apis[campaign_id]
			# called more than once for the same campaign; return the existing campaign_api
			next @mailchimp_campaign_apis[campaign_id][:campaign_api]
		end
	
		campaign_api = double('Struct::CampaignAPI').as_null_object
		@mailchimp_campaign_apis[campaign_id] = { campaign_api: campaign_api }
		
		if campaign_id
			# update a campaign
			allow(campaign_api).to receive(:update) do |arg|
				response = @mailchimp_campaigns[campaign_id][:response]
				raise resource_not_found_exception unless response
				
				body = arg[:body] || {}
				unless body[:settings]
					raise invalid_resource_exception([
						{'field' => '', 'message' => 'Required fields were not provided: settings'}
					])
				end
				if body[:recipients] && body[:recipients][:list_id].blank?
					raise invalid_resource_exception([
						{'field' => 'recipients', 'message' => 'Required fields were not provided: list_id'}
					])
				end
				
				response.merge! copy_hash_and_stringify_keys(body)
				@mailchimp_campaigns[campaign_id][:folder_id] = response['settings']['folder_id'].presence
				
				log_campaign_api_info :update, campaign_id, response
				
				response
			end
		
		else # no campaign_id needed for these methods
			# create a campaign
			allow(campaign_api).to receive(:create) do |arg|
				body = arg[:body] || {}
				unless body[:type]
					raise invalid_resource_exception([
						{'field' => '', 'message' => 'Required fields were not provided: type'}
					])
				end
				unless body[:settings]
					raise invalid_resource_exception([
						{'field' => '', 'message' => 'Required fields were not provided: settings'}
					])
				end
				if body[:recipients] && body[:recipients][:list_id].blank?
					raise invalid_resource_exception([
						{'field' => 'recipients', 'message' => 'Required fields were not provided: list_id'}
					])
				end

				folder_id = body[:settings][:folder_id]
				body['id'] = id = "#{@mailchimp_campaign_id += 1}"
				response = campaign_api_response(body)
				@mailchimp_campaigns[id] = { response: response, folder_id: folder_id }
				
				log_campaign_api_info :create, campaign_id, response
				
				response
			end
		end
		
		# retrieve campaign(s)
		allow(campaign_api).to receive(:retrieve) do |arg|
			if campaign_id
				# single campaign
				response = @mailchimp_campaigns[campaign_id][:response]
				raise resource_not_found_exception unless response
				
				log_campaign_api_info :retrieve, campaign_id, response
				
				response
			else
				# multiple campaigns
				folder_id = nil
				if arg && arg[:params] # Parse optional parameters.
					folder_id = arg[:params][:folder_id]
					offset = arg[:params][:offset].presence.try(:to_i)
					count = arg[:params][:count].presence.try(:to_i)
				end
				# Default values of MailChimp API.
				offset ||= 0
				count ||= 10
				
				ids = @mailchimp_campaigns.keys.sort # Sort so that offset calls will work.
				ids_slice = ids[offset, (ids.size - offset)] || []
				found = 0
				
				response_list = ids_slice.map do |id|
					campaign = @mailchimp_campaigns[id]
					if found < count && (folder_id.blank? || campaign[:folder_id] == folder_id)
						found += 1
						campaign[:response]
					else
						nil
					end
				end
				
				response = { 'campaigns' => response_list.compact }
				
				log_campaign_api_info :retrieve, campaign_id, response
				
				response
			end
		end
	
		# retrieve campaign content
		Struct.new 'CampaignContentAPI' unless defined? Struct::CampaignContentAPI
		campaign_content_api = double('Struct::CampaignContentAPI').as_null_object
	
		allow(campaign_api).to receive(:content).and_return(campaign_content_api)
	
		allow(campaign_content_api).to receive(:retrieve).and_return(
			{
				'plain_text' => 'THIS WEEKEND: sport events.',
				'html' => '<!DOCTYPE html><html><head></head><body>THIS WEEKEND: sport events.</body></html>'
			}
		)
		
		if campaign_id
			# actions on a single campaign
			Struct.new 'CampaignActionsAPI' unless defined? Struct::CampaignActionsAPI
			campaign_actions_api = double('Struct::CampaignActionsAPI').as_null_object
			allow(campaign_api).to receive(:actions).and_return(campaign_actions_api)
			
			Struct.new 'CampaignActionsSendAPI' unless defined? Struct::CampaignActionsSendAPI
			campaign_actions_send_api = double('Struct::CampaignActionsSendAPI').as_null_object
			allow(campaign_actions_api).to receive(:send).and_return(campaign_actions_send_api)
			
			allow(campaign_actions_send_api).to receive(:create) do
				if (campaign = @mailchimp_campaigns[campaign_id])
					response = campaign[:response]
					response['status'] = 'sent'
					response['send_time'] = Time.now.to_s
				else
					raise resource_not_found_exception
				end
				
				log_campaign_api_info 'actions.send.create', campaign_id, response
				
				nil
			end
			
			Struct.new 'CampaignActionsReplicateAPI' unless defined? Struct::CampaignActionsReplicateAPI
			campaign_actions_replicate_api = double('Struct::CampaignActionsReplicateAPI').as_null_object
			allow(campaign_actions_api).to receive(:replicate).and_return(campaign_actions_replicate_api)
			
			allow(campaign_actions_replicate_api).to receive(:create) do
				source_campaign = @mailchimp_campaigns[campaign_id]
				raise resource_not_found_exception unless source_campaign
				
				response = copy_hash_and_stringify_keys source_campaign[:response]
				response['id'] = id = "#{@mailchimp_campaign_id += 1}"
				response['settings']['title'] = "#{response['settings']['title']} (copy 01)"
				@mailchimp_campaigns[id] = { response: response, folder_id: source_campaign[:folder_id] }
				
				log_campaign_api_info 'actions.replicate.create', campaign_id, response
				
				response
			end
			
			Struct.new 'CampaignActionsScheduleAPI' unless defined? Struct::CampaignActionsScheduleAPI
			campaign_actions_schedule_api = double('Struct::CampaignActionsScheduleAPI').as_null_object
			allow(campaign_actions_api).to receive(:schedule).and_return(campaign_actions_schedule_api)
			
			allow(campaign_actions_schedule_api).to receive(:create) do |arg|
				campaign = @mailchimp_campaigns[campaign_id]
				raise resource_not_found_exception unless campaign
				
				body = arg[:body] || {}
				unless body[:schedule_time]
					raise invalid_resource_exception([
						{'field' => '', 'message' => 'Required fields were not provided: schedule_time'}
					])
				end
				
				response = campaign[:response]
				response['status'] = 'schedule'
				response['send_time'] = body[:schedule_time]
				
				log_campaign_api_info 'actions.schedule.create', campaign_id, response
				
				nil
			end
		end
		
		campaign_api
	end
end

def campaign_api_response(body={})
	response = {
		'id' => 'c123',
		'status' => 'save',
		'send_time' => '',
		'archive_url' => 'http://example.com',
		'recipients' => {
			'list_id' => 'abc123'
		},
		'settings' => { }
	}
	
	response.merge(copy_hash_and_stringify_keys(body))
end

def copy_hash_and_stringify_keys(h)
	h_copy = {}
	h.each do |key, value|
		h_copy[key.to_s] = (value.is_a?(Hash) ? copy_hash_and_stringify_keys(value) : value)
	end
	h_copy
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
	[:parent_newsletters_source_campaigns, :parent_newsletters_campaigns]
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
