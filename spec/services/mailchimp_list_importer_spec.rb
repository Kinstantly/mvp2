require 'spec_helper'

describe MailchimpListImporter, mailchimp: true do
	let(:list) { :parent_newsletters }
	let(:list_id) { mailchimp_list_ids[list] }
	
	let(:list_importer_params) { {
		list: list
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
					status: 'subscribed'
				}
			end
			
			expect {
				list_importer.call
			}.to change(Subscription, :count).by(email_list.size)
		end
		
		it "should import the subscriber's email address" do
			email = 'subscriber@kinstantly.com'
			
			Gibbon::Request.lists(list_id).members(email_md5_hash(email)).upsert body: {
				email_address: email,
				status: 'subscribed'
			}
			
			list_importer.call
			subscriber = Subscription.last
			expect(subscriber.email).to eq email
		end
		
		it "should import the birth dates of the subscriber's children" do
			email = 'subscriber@kinstantly.com'
			birth1, birth2 = Date.new(2017, 5, 1), Date.new(2012, 10, 23)
			
			Gibbon::Request.lists(list_id).members(email_md5_hash(email)).upsert body: {
				email_address: email,
				status: 'subscribed',
				merge_fields: {
					'DUEBIRTH1' => birth1.strftime('%-m/%-d/%Y'),
					'BIRTH2' => birth2.strftime('%-m/%-d/%Y')
				}
			}
			
			list_importer.call
			subscriber = Subscription.last
			expect([subscriber.birth1, subscriber.birth2]).to eq [birth1, birth2]
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
