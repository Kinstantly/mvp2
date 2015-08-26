require 'spec_helper'

describe MailchimpWebhookController, :type => :controller do
	let(:token) { Rails.configuration.mailchimp_webhook_security_token }
	let(:list_id) { mailchimp_list_ids[:parent_newsletters_stage1]}
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
			expect(response.status).to eq 200
		end

		context "user unsubscribed remotely, but still subscribed locally" do
			before(:example) do
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
				expect(user.parent_newsletters_stage1).to eq true
				expect(user.parent_newsletters_stage1_leid).to eq @parent_newsletters_stage1_leid
			end

			it "should not process notification with invalid request params" do
				params.delete(:type)
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters_stage1).to eq true
				expect(user.parent_newsletters_stage1_leid).to eq @parent_newsletters_stage1_leid
			end
			
			it "removes subscription when valid unsubscribe notification received" do
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters_stage1).to eq false
				expect(user.parent_newsletters_stage1_leid).to eq nil
			end
			
			it 'logs it if the reason for unsubscribing is abuse' do
				params[:data][:reason] = 'abuse'
				logger = double 'logger'
				expect(logger).to receive(:info).with(/abuse/)
				allow_any_instance_of(MailchimpWebhookController).to receive(:logger).and_return(logger)
				post :process_notification, params
			end
		end

		context "user subscribed both locally and remotely" do
			before(:example) do
				user.parent_newsletters_stage1 = true
				user.parent_newsletters_stage2 = true
				user.parent_newsletters_stage3 = true
				user.provider_newsletters = true
				user.save!
			end
			
			it "should NOT remove subscriptions" do
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters_stage1).to be_truthy
				expect(user.parent_newsletters_stage2).to be_truthy
				expect(user.parent_newsletters_stage3).to be_truthy
				expect(user.provider_newsletters).to be_truthy
				expect(user.parent_newsletters_stage1_leid).to be_present
				expect(user.parent_newsletters_stage2_leid).to be_present
				expect(user.parent_newsletters_stage3_leid).to be_present
				expect(user.provider_newsletters_leid).to be_present
			end
			
			it "should remove one subscription" do
				Gibbon::API.new.lists.unsubscribe id: list_id,
					email: {email: user.email, leid: user.parent_newsletters_stage1_leid},
					delete_member: true, send_goodbye: false, send_notify: false
				
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters_stage1).not_to be_truthy
				expect(user.parent_newsletters_stage2).to be_truthy
				expect(user.parent_newsletters_stage3).to be_truthy
				expect(user.provider_newsletters).to be_truthy
				expect(user.parent_newsletters_stage1_leid).not_to be_present
				expect(user.parent_newsletters_stage2_leid).to be_present
				expect(user.parent_newsletters_stage3_leid).to be_present
				expect(user.provider_newsletters_leid).to be_present
			end
		end

		context 'user never subscribed' do
		  it 'should handle unsubscribe notification gracefully' do
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters_stage1).not_to be_truthy
		  end
		end

		context "new campaign sent" do
			# The following works because we are mocking the campaigns API.
			it "creates a new record when valid campaign data provided" do
				post :process_notification, campaign_params
				new_newsletter = Newsletter.find_by_cid(campaign_params[:data][:id])
				expect(new_newsletter).to be_present
				expect(new_newsletter.cid).to eq campaign_params[:data][:id]
			end
			
			it "does not create a new record when invalid campaign data provided" do
				post :process_notification, campaign_params.merge(data: {id: nil})
				new_newsletter = Newsletter.find_by_cid(campaign_params[:data][:id])
				expect(new_newsletter).to be_nil
			end
			
			it 'will not duplicate the record when notified twice of the same campaign' do
				post :process_notification, campaign_params
				post :process_notification, campaign_params
				expect(Newsletter.where(cid: campaign_params[:data][:id]).size).to eq 1
			end
		end
	end
end
