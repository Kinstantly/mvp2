
def mailing_lists
	['parent_newsletters_stage1', 'parent_newsletters_stage2', 'parent_newsletters_stage3', 'provider_newsletters']
end

# Make sure all of the test mailing lists are empty.
def empty_mailing_lists
	begin
		gb = Gibbon::API.new
		mailing_lists.each do |list_name|
			list_id = Rails.configuration.mailchimp_list_id[list_name.to_sym]
			gb.lists.members(id: list_id)['data'].each do |member|
				gb.lists.unsubscribe id: list_id, email: {email: member['email']}, delete_member: true, send_notify: false
			end
		end
	rescue Gibbon::MailChimpError => e
		puts "MailChimp error while unsubscribing: #{e.message}, error code: #{e.code}"
	end
end
