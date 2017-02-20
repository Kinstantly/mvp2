require 'spec_helper'

describe MailchimpWebhookController, type: :controller, mailchimp: true do
	let(:token) { Rails.configuration.mailchimp_webhook_security_token }
	let(:list_id) { mailchimp_list_ids[:parent_newsletters]}
	let(:user) { FactoryGirl.create(:client_user) }
	let(:params) {{ type: "unsubscribe", token: token, data: {list_id: list_id, email: user.email }}}
	
	describe "POST process_notification" do
		
		it "returns a status of 200 no matter what" do
			post :process_notification, token: 'none'
			expect(response.status).to eq 200
		end

		context "user unsubscribed remotely, but still subscribed locally" do
			before(:example) do
				user.parent_newsletters = true
				user.save!
				@parent_newsletters_leid = user.parent_newsletters_leid
	
				# Unsubscribe without deleting user from the list
				email_hash = Digest::MD5.hexdigest user.email.downcase
				Gibbon::Request.lists(list_id).members(email_hash).update body: {
					status: 'unsubscribed'
				}
			end

			it "should not process notification without a valid token" do
				params[:token] = "none"
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters).to eq true
				expect(user.parent_newsletters_leid).to eq @parent_newsletters_leid
			end

			it "should not process notification with invalid request params" do
				params.delete(:type)
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters).to eq true
				expect(user.parent_newsletters_leid).to eq @parent_newsletters_leid
			end
			
			it "removes subscription when valid unsubscribe notification received" do
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters).to eq false
				expect(user.parent_newsletters_leid).to eq nil
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
				user.parent_newsletters = true
				user.provider_newsletters = true
				user.save!
			end
			
			it "should NOT remove subscriptions" do
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters).to be_truthy
				expect(user.provider_newsletters).to be_truthy
				expect(user.parent_newsletters_leid).to be_present
				expect(user.provider_newsletters_leid).to be_present
			end
			
			it "should remove one subscription" do
				email_hash = Digest::MD5.hexdigest user.email.downcase
				Gibbon::Request.lists(list_id).members(email_hash).update body: {
					status: 'unsubscribed'
				}
				
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters).not_to be_truthy
				expect(user.provider_newsletters).to be_truthy
				expect(user.parent_newsletters_leid).not_to be_present
				expect(user.provider_newsletters_leid).to be_present
			end
		end

		context 'user never subscribed' do
		  it 'should handle unsubscribe notification gracefully' do
				post :process_notification, params
				user.reload
				expect(user.parent_newsletters).not_to be_truthy
		  end
		end

		# Because these examples are sending the campaign, require mocks. Thus we won't send real emails.
		context "new campaign sent", use_gibbon_mocks: true do
			let(:body) {
				{
					type: 'regular',
					recipients: {
						list_id: list_id
					},
					settings: {
						folder_id: nil,
						title: '3 YEARS, 1 month',
						subject_line: 'Your Child is 3 YEARS, 1 month',
						from_name: 'Kinstantly',
						reply_to: 'kinstantly@kinstantly.com'
					}
				}
			}
			
			let(:campaign) {
				response = Gibbon::Request.campaigns.create body: body
				Gibbon::Request.campaigns(response['id']).actions.send.create
				response
			}
			
			let(:campaign_params) {
				{
					type: 'campaign', 
					token: token, 
					data: {
						id: campaign['id'],
						list_id: list_id,
						send_time: campaign['send_time'],
						title: campaign['settings']['title'],
						subject: campaign['settings']['subject_line'],
						archive_url: campaign['archive_url']
					}
				}
			}
			
			it "creates a new record when valid campaign data provided" do
				expect {
					post :process_notification, campaign_params
				}.to change(Newsletter, :count).by(1)
				expect(Newsletter.find_by_cid campaign_params[:data][:id]).to be_present
			end
			
			it "does not create a new record when invalid campaign data provided" do
				expect {
					post :process_notification, campaign_params.merge(data: {id: nil})
				}.to_not change(Newsletter, :count)
			end
			
			it 'will not duplicate the record when notified twice of the same campaign' do
				expect {
					post :process_notification, campaign_params
					post :process_notification, campaign_params
				}.to change(Newsletter, :count).by(1)
				expect(Newsletter.where(cid: campaign_params[:data][:id]).size).to eq 1
			end
			
			it "does not create a new record when a stage-based campaign was sent" do
				body[:settings][:folder_id] = mailchimp_folder_ids[:parent_newsletters_campaigns]
				expect {
					post :process_notification, campaign_params
				}.to_not change(Newsletter, :count)
			end
		end
	end
end
