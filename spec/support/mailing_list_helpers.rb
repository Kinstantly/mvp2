# This file is required by features/support/env.rb for Cucumber scenarios.
# So make sure everything in here is compatible with Cucumber using RSpec mocks.

def set_up_gibbon_mocks
	set_up_gibbon_lists_api_mock
	set_up_gibbon_campaigns_api_mock
end

def set_up_gibbon_lists_api_mock
	Struct.new 'GibbonListsAPI' unless defined? Struct::GibbonListsAPI
	lists_api = double('Struct::GibbonListsAPI').as_null_object
	
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
	allow_any_instance_of(Gibbon::API).to receive(:lists).and_return(lists_api)
end

def set_up_gibbon_campaigns_api_mock
	Struct.new 'GibbonCampaignsAPI' unless defined? Struct::GibbonCampaignsAPI
	campaigns_api = double('Struct::GibbonCampaignsAPI').as_null_object
	
	# list
	allow(campaigns_api).to receive(:list) do |options| # filters: filters
		id = options[:filters][:campaign_id]
		if id.present?
			data = [{
				'id' => id,
				'list_id' => 'abc123',
				'send_time' => Time.zone.now,
				'title' => 'Latest parenting news',
				'subject' => 'THIS WEEKEND: sport events',
				'archive_url' => 'http://example.com'
			}]
			{ 'data' => data }
		else
			raise Gibbon::MailChimpError, "campaigns.list(): campaign_id => #{id}"
		end
	end
	
	# content
	allow(campaigns_api).to receive(:content) do |options| # cid: id
		id = options[:cid]
		if id.present?
			{ 'html' => '<!DOCTYPE html><html><head></head><body>THIS WEEKEND: sport events.</body></html>' }
		else
			raise Gibbon::MailChimpError, "campaigns.content(): cid => #{id}"
		end
	end
	
	# campaigns API
	allow_any_instance_of(Gibbon::API).to receive(:campaigns).and_return(campaigns_api)
end

def mailing_lists
	['parent_newsletters', 'provider_newsletters']
end

# Make sure all of the test mailing lists are empty.
def empty_mailing_lists
	begin
		gb = Gibbon::API.new
		mailing_lists.each do |list_name|
			list_id = Rails.configuration.mailing_lists[:mailchimp_list_ids][list_name.to_sym]
			gb.lists.members(id: list_id)['data'].each do |member|
				gb.lists.unsubscribe id: list_id, email: {email: member['email']}, delete_member: true, send_notify: false
			end
		end
	rescue Gibbon::MailChimpError => e
		puts "MailChimp error while unsubscribing: #{e.message}, error code: #{e.code}"
	end
end

# Get info for a particular member of the specified list.
def member_of_mailing_list(email, list_name)
	begin
		gb = Gibbon::API.new
		list_id = Rails.configuration.mailing_lists[:mailchimp_list_ids][list_name.to_sym]
		gb.lists.member_info(id: list_id, emails: [{email: email}])['data'][0]
	rescue Gibbon::MailChimpError => e
		puts "MailChimp error while retrieving member info: #{e.message}, error code: #{e.code}"
	end
end
