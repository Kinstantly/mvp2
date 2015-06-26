require 'spec_helper'

describe MailchimpWebhookController do
	let(:token) { Rails.configuration.mailchimp_webhook_security_token }
	let(:list_id) { Rails.configuration.mailchimp_list_id[:parent_newsletters_stage1]}	
	let(:user) { FactoryGirl.create(:client_user) }
	let(:params) {{ type: "unsubscribe", token: token, data: {list_id: list_id, email: user.email }}}
	let(:campaign_params) {
		{ type: "campaign", 
			token: token, 
			data: { id: '123', list_id: list_id, 
				send_time: DateTime.now, title: 'Latest parenting news', subject: 'THIS WEEKEND: sport events',
				archive_url: 'http://example.com' 
			}
		}
	}
	describe "POST process_notification", mailchimp: true do
		
		it "returns a status of 200 no matter what" do
			post :process_notification, token: 'none'
			response.status.should == 200
		end

		context "user unsubscribed remotely, but still subscribed locally" do
			before(:each) do
				user.parent_newsletters_stage1 = true
				user.save!
				@parent_newsletters_stage1_leid = user.parent_newsletters_stage1_leid
	
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
				user.parent_newsletters_stage1.should == true
				user.parent_newsletters_stage1_leid.should == @parent_newsletters_stage1_leid
			end

			it "should not process notification with invalid request params" do
				params.delete(:type)
				post :process_notification, params
				user.reload
				user.parent_newsletters_stage1.should == true
				user.parent_newsletters_stage1_leid.should == @parent_newsletters_stage1_leid
			end
			
			it "removes subscription when valid unsubscribe notification received" do
				post :process_notification, params
				user.reload
				user.parent_newsletters_stage1.should == false
				user.parent_newsletters_stage1_leid.should == nil
			end
		end

		context "user subscribed both locally and remotely" do
			before(:each) do
				user.parent_newsletters_stage1 = true
				user.parent_newsletters_stage2 = true
				user.parent_newsletters_stage3 = true
				user.provider_newsletters = true
				user.save!
			end
			
			it "should NOT remove subscriptions" do
				post :process_notification, params
				user.reload
				user.parent_newsletters_stage1.should be_true
				user.parent_newsletters_stage2.should be_true
				user.parent_newsletters_stage3.should be_true
				user.provider_newsletters.should be_true
				user.parent_newsletters_stage1_leid.should be_present
				user.parent_newsletters_stage2_leid.should be_present
				user.parent_newsletters_stage3_leid.should be_present
				user.provider_newsletters_leid.should be_present
			end
			
			it "should remove one subscription" do
				Gibbon::API.new.lists.unsubscribe id: list_id,
					email: {email: user.email, leid: user.parent_newsletters_stage1_leid},
					delete_member: true, send_goodbye: false, send_notify: false
				
				post :process_notification, params
				user.reload
				user.parent_newsletters_stage1.should_not be_true
				user.parent_newsletters_stage2.should be_true
				user.parent_newsletters_stage3.should be_true
				user.provider_newsletters.should be_true
				user.parent_newsletters_stage1_leid.should_not be_present
				user.parent_newsletters_stage2_leid.should be_present
				user.parent_newsletters_stage3_leid.should be_present
				user.provider_newsletters_leid.should be_present
			end
		end

		context "new campaign sent" do
			# The following works because we are mocking the campaigns API.
			it "creates a new record when valid campaign data provided" do
				post :process_notification, campaign_params
				new_newsletter = Newsletter.find_by_cid(campaign_params[:data][:id])
				new_newsletter.should be_present
				new_newsletter.cid.should == campaign_params[:data][:id]
			end
			
			it "does not create a new record when invalid campaign data provided" do
				post :process_notification, campaign_params.merge(data: {id: nil})
				new_newsletter = Newsletter.find_by_cid(campaign_params[:data][:id])
				new_newsletter.should be_nil
			end
		end
	end
end
