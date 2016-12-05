# This file is required by features/support/env.rb for Cucumber scenarios.
# So make sure everything in here is compatible with Cucumber using RSpec mocks.

include NewsletterSubscriptionHelpers

def set_up_gibbon_mocks
	set_up_gibbon_lists_api_mock
	set_up_gibbon_campaigns_api_mock
end

def set_up_gibbon_lists_api_mock
	Struct.new 'GibbonRequest' unless defined? Struct::GibbonRequest
	lists_api = double('Struct::GibbonRequest').as_null_object
	
	@mailchimp_lists = {}
	
	# subscribe
	allow(lists_api).to receive(:subscribe) do |options| # id: list_id
		id = options[:id]
		email = options[:email][:email]
		if id.present? and email.present?
			options[:merge_vars] ||= {}
			options[:merge_vars]['EMAIL'] = email
			@mailchimp_lists[id] ||= {}
			@mailchimp_lists[id][email] = options.merge 'leid' => "#{id}:#{email}", 'status' => 'subscribed'
		else
			raise Gibbon::MailChimpError, "lists.subscribe(): list ID => #{id}, email => #{email}"
		end
	end
	
	# unsubscribe
	allow(lists_api).to receive(:unsubscribe) do |options| # id: list_id
		id = options[:id]
		email = options[:email][:email]
		if id.present? and email.present?
			@mailchimp_lists[id] ||= {}
			if options[:delete_member]
				@mailchimp_lists[id][email] = nil
			elsif (info = @mailchimp_lists[id][email])
				info['status'] = 'unsubscribed'
			else
				raise Gibbon::MailChimpError, "lists.unsubscribe(): list ID => #{id}, email => #{email}, info => #{info}"
			end
		else
			raise Gibbon::MailChimpError, "lists.unsubscribe(): list ID => #{id}, email => #{email}"
		end
	end
	
	# member_info
	allow(lists_api).to receive(:member_info) do |options| # id: list_id, emails: array_of_hashes
		r = { 'success_count' => 0, 'error_count' => 0, 'data' => [] }
		id = options[:id]
		email_info_list = options[:emails]
		if id.present? and email_info_list.present?
			@mailchimp_lists[id] ||= {}
			email_info_list.each do |email_info|
				email = email_info[:email]
				info = @mailchimp_lists[id][email]
				if info.present?
					r['success_count'] += 1
					r['data'] << info.merge('email' => email, 'merges' => info[:merge_vars])
				else
					r['error_count'] += 1
				end
			end
			r
		else
			raise Gibbon::MailChimpError, "lists.member_info(): list ID => #{id}, emails => #{email_info_list}"
		end
	end
	
	# members
	allow(lists_api).to receive(:members) do |options| # id: list_id, status: status_value
		r = { 'total' => 0, 'data' => [] }
		id = options[:id]
		status = options[:status].presence || 'subscribed'
		if id.present?
			@mailchimp_lists[id] ||= {}
			@mailchimp_lists[id].each do |email, info|
				if info['status'] == status
					r['total'] += 1
					r['data'] << { 'email' => email, 'status' => info['status'], 'merges' => info[:merge_vars] }
				end
			end
			r
		else
			raise Gibbon::MailChimpError, "lists.member_info(): list ID => #{id}, status => #{status}"
		end
	end
	
	# lists API
	allow_any_instance_of(Gibbon::Request).to receive(:lists).and_return(lists_api)
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
		puts "MailChimp error while unsubscribing: #{e.title}; #{e.detail}; status: #{e.status_code}"
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
