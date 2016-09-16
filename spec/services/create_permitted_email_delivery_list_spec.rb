require 'spec_helper'

describe CreatePermittedEmailDeliveryList do
	let(:email_1) { 'a@example.org' }
	let(:email_2) { 'b@example.com' }
	let(:email_3) { 'c@example.org' }
	let(:create_list_params) { {
		sender: 'me@example.com',
		email_type: 'provider_sell',
		email_list: "#{email_1}\n#{email_2}\n#{email_3}"
	} }
	let(:create_list_service) { CreatePermittedEmailDeliveryList.new(create_list_params) }

	let(:create_list_service_error) {
		CreatePermittedEmailDeliveryList.new(create_list_params.merge email_list: "#{email_1}\n@expect.com\n#{email_3}")
	}
	
	context 'with valid parameters' do
		let!(:create_list_service_call) { create_list_service.call }
	
		it 'should return success' do
			expect(create_list_service_call).to be_truthy
		end
	
		it 'should have a success status' do
			expect(create_list_service).to be_successful
		end
		
		it 'should have no errors' do
		  expect(create_list_service.errors).to be_empty
		end
		
		it 'should have a list of email delivery records' do
			expect(create_list_service.email_deliveries.size).to eq 3
		end
	
		it 'should have a string list of email addresses' do
			expect(create_list_service.email_unsubscribe_list_string).to include(email_1, email_2, email_3)
		end
	
		it 'should have a string list containing the corresponding unsubscribe URLs' do
			unsubscribe_urls = create_list_service.email_deliveries.map do |email_delivery|
				Rails.application.routes.url_helpers.new_contact_blocker_from_email_delivery_url email_delivery_token: email_delivery.token, host: default_host
			end
			expect(unsubscribe_urls.size).to eq 3
			expect(create_list_service.email_unsubscribe_list_string).to include(*unsubscribe_urls)
		end
		
		it 'should destroy the email delivery records' do
			expect {
				create_list_service.destroy
			}.to change(EmailDelivery, :count).by(-3)
		end
	end
	
	it 'should create new email delivery records' do
		expect {
			create_list_service.call
		}.to change(EmailDelivery, :count).by(3)
	end
	
	context 'with a blocked recipient' do
		before(:each) do
			FactoryGirl.create :contact_blocker, email: email_2
		end
		
		it 'should create one less email delivery record' do
			expect {
				create_list_service.call
			}.to change(EmailDelivery, :count).by(2)
		end
		
		it 'should not create an email delivery record for the blocked recipient' do
			create_list_service.call
			expect(create_list_service.email_deliveries.map &:recipient).not_to include(email_2)
		end
		
		it 'should not include the blocked recipient in the email unsubscribe list' do
			create_list_service.call
			expect(create_list_service.email_unsubscribe_list_string).not_to include(email_2)
		end
		
		it 'should let you know which recipients should not be sent to' do
			create_list_service.call
			expect(create_list_service.blocked_recipients).to include(email_2)
		end
	end
	
	context 'with invalid parameters' do
		let!(:create_list_service_call_error) { create_list_service_error.call }
		
		it 'should not return success' do
			expect(create_list_service_call_error).to be_falsey
		end
	
		it 'should not have a success status' do
			expect(create_list_service_error).not_to be_successful
		end
		
		it 'should have errors' do
		  expect(create_list_service_error.errors).to be_present
		end
	end
end
