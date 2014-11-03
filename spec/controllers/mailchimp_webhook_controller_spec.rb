require 'spec_helper'

describe MailchimpWebhookController do
	let(:token) { Rails.configuration.mailchimp_webhook_security_token }
	let(:list_id) { Rails.configuration.mailchimp_list_id }
	let(:notification_type) { "unsubscribe" }		
	let(:user) { FactoryGirl.create(:client_user) }
	let(:params) { {type: notification_type, token: token, data: {list_id: list_id, email: user.email}} }
	
	describe "POST process_notification", mailchimp_webhook: true do
		
		it "returns a status of 200 no matter what" do
			post :process_notification, token: 'none'
			response.status.should == 200
		end

		context "user unsubscribed remotely, but still subscribed locally" do
			before(:each) do
				user.subscriber_euid = '123'
				user.subscriber_leid = '123'
				user.save!
			end

			it "should not process notification without a valid token" do
				params[:token] = "none"
				post :process_notification, params
				user.reload
				user.subscriber_euid.should == '123'
				user.subscriber_leid.should == '123'
			end

			it "should not process notification with invalid request params" do
				params.delete(:type)
				post :process_notification, params
				user.reload
				user.subscriber_euid.should == '123'
				user.subscriber_leid.should == '123'
			end
			
			it "removes subscription when valid unsubscribe notification received for subscribed user" do
				post :process_notification, params
				user.reload
				user.subscriber_euid.should == nil
				user.subscriber_leid.should == nil
			end
		end

		context "user subscribed both locally and remotely" do
			after(:each) do
				user.unsubscribe_from_mailing_list
			end
			it "should not remove subscription" do
				user.parent_marketing_emails = true
				user.parent_newsletters = true
				user.provider_marketing_emails = true
				user.provider_newsletters = true
				user.save!

				post :process_notification, params
				user.reload
				user.parent_marketing_emails.should == true
				user.parent_newsletters.should == true
				user.provider_marketing_emails.should == true
				user.provider_newsletters.should == true
				user.subscriber_euid.should_not == nil
				user.subscriber_leid.should_not == nil
			end
		end
	end
end
