require 'spec_helper'

describe MailchimpListImporter do
	let(:list) { :parent_newsletters }
	let(:list_id) { mailchimp_list_ids[list] }
	
	let(:list_importer_params) { {
		list: list,
		limit: 3, # Implement count and offset in list members API mock, then remove this line!!
		verbose: 't'
	} }
	let(:list_importer) { MailchimpListImporter.new(list_importer_params) }

	let(:list_importer_error) {
		MailchimpListImporter.new(list_importer_params.merge list: nil)
	}
	
	context 'with valid parameters' do
		it 'should return success' do
			expect(list_importer.call).to be_truthy
		end
	
		it 'should have a success status' do
			list_importer.call
			expect(list_importer).to be_successful
		end
		
		it 'should create subscription records' do
			email_list = [
				'subscriber1@kinstantly.com',
				'subscriber2@kinstantly.com',
				'subscriber3@kinstantly.com'
			]
			
			email_list.each do |email|
				Gibbon::Request.lists(list_id).members(email_md5_hash(email)).upsert body: {
					email_address: email,
					status: 'subscribed',
					merge_fields: {}
				}
			end
			
			expect {
				list_importer.call 
			}.to change(Subscription, :count).by(email_list.size)
		end
	end
	
	context 'with invalid parameters' do
		it 'should not return success' do
			expect(list_importer_error.call).to be_falsey
		end
	
		it 'should not have a success status' do
			list_importer_error.call
			expect(list_importer_error).not_to be_successful
		end
	end
end
