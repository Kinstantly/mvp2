require 'spec_helper'

describe MailchimpWebhookController do
	let(:token) { Rails.configuration.mailchimp_webhook_security_token }
	let(:list_id) { Rails.configuration.mailchimp_list_id[:parent_marketing_emails]}	
	let(:user) { FactoryGirl.create(:client_user) }
	let(:params) { {type: "unsubscribe", token: token, data: {list_id: list_id, email: user.email}} }
	
	describe "POST process_notification", mailchimp: true do
		
		it "returns a status of 200 no matter what" do
			post :process_notification, token: 'none'
			response.status.should == 200
		end

		context "user unsubscribed remotely, but still subscribed locally" do
			before(:each) do
				user.parent_marketing_emails = true
				user.save!
				@parent_marketing_emails_leid = user.parent_marketing_emails_leid
	
				# Unsubscribe without deleting user from the list
				gb = Gibbon::API.new
				r = gb.lists.unsubscribe id: list_id, 
					email: { email: user.email },
					send_goodbye: false,
					send_notify: false
			end

			it "should not process notification without a valid token" do
				params[:token] = "none"
				post :process_notification, params
				user.reload
				user.parent_marketing_emails.should == true
				user.parent_marketing_emails_leid.should == @parent_marketing_emails_leid
			end

			it "should not process notification with invalid request params" do
				params.delete(:type)
				post :process_notification, params
				user.reload
				user.parent_marketing_emails.should == true
				user.parent_marketing_emails_leid.should == @parent_marketing_emails_leid
			end
			
			it "removes subscription when valid unsubscribe notification received" do
				post :process_notification, params
				user.reload
				user.parent_marketing_emails.should == false
				user.parent_marketing_emails_leid.should == nil
			end
		end

		context "user subscribed both locally and remotely" do
			after(:each) do
				# Remove user from all mailing lists
				user.send(:unsubscribe_from_mailing_lists, Rails.configuration.mailchimp_list_id.keys)
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
				user.parent_marketing_emails_leid.should_not == nil
				user.parent_newsletters_leid.should_not == nil
				user.provider_marketing_emails_leid.should_not == nil
				user.provider_newsletters_leid.should_not == nil
			end
		end
	end
end
