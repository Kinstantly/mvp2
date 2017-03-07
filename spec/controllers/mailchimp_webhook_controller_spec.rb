require 'spec_helper'

describe MailchimpWebhookController, type: :controller, mailchimp: true do
	let(:token) { Rails.configuration.mailchimp_webhook_security_token }
	let(:list_id) { mailchimp_list_ids[:parent_newsletters]}
	let(:subscriber_email) { 'subscriber_1@kinstantly.com' }
	let(:user) { FactoryGirl.create(:client_user, email: subscriber_email) }
	let(:params) {
		{
			type: "unsubscribe",
			token: token,
			data: {
				list_id: list_id,
				email: subscriber_email
			}
		}
	}
	
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
				email_hash = email_md5_hash user.email
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
				email_hash = email_md5_hash user.email
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

		context 'subscriber deleted from list' do
			before(:example) do
				user.parent_newsletters = true
				user.save!
				email_hash = email_md5_hash user.email
				Gibbon::Request.lists(list_id).members(email_hash).delete
			end
			
			it 'should unsubscribe the user locally' do
				expect {
					post :process_notification, params
				}.to change {
					user.reload.parent_newsletters
				}.from(true).to(false)
			end
		end
		
		context 'subscriptions with no local user account' do
			let(:email_hash) { email_md5_hash subscriber_email }
			let(:member) {
				Gibbon::Request.lists(list_id).members(email_hash).upsert body: {
					email_address: subscriber_email,
					status: 'unsubscribed'
				}
			}
			let!(:subscription) {
				FactoryGirl.create :subscription, {
					list_id: member['list_id'],
					email: member['email_address'],
					unique_email_id: member['unique_email_id'],
					status: 'subscribed'
				}
			}
			
			it 'should mark the subscription record as not subscribed' do
				expect {
					post :process_notification, params
				}.to change {
					subscription.reload.subscribed
				}.from(true).to(false)
			end
			
			it 'should mark the subscription record as not subscribed even if deleted remotely' do
				Gibbon::Request.lists(list_id).members(email_hash).delete
				
				expect {
					post :process_notification, params
				}.to change {
					subscription.reload.subscribed
				}.from(true).to(false)
			end
		end
		
		# Because these examples are sending the campaign, require mocks. Thus we won't send real emails.
		context "campaign sent", use_gibbon_mocks: true do
			let(:title) { '3 YEARS, 1 month' }
			
			let(:body) {
				{
					type: 'regular',
					recipients: {
						list_id: list_id
					},
					settings: {
						folder_id: nil,
						title: title,
						subject_line: title,
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
			
			it "should archive the campaign when valid data is provided" do
				expect {
					post :process_notification, campaign_params
				}.to change(Newsletter, :count).by(1)
				expect(Newsletter.find_by_cid campaign_params[:data][:id]).to be_present
			end
			
			it "should not archive the campaign when invalid data is provided" do
				expect {
					post :process_notification, campaign_params.merge(data: {id: nil})
				}.to_not change(Newsletter, :count)
			end
			
			it 'should not create a duplicate archive when notified twice of the same campaign' do
				expect {
					post :process_notification, campaign_params
					post :process_notification, campaign_params
				}.to change(Newsletter, :count).by(1)
				expect(Newsletter.where(cid: campaign_params[:data][:id]).size).to eq 1
			end
			
			context 'as stage-based newsletter' do
				let(:subscriber_email) { 'subscriber_1@kinstantly.com' }
				
				let(:segment) {
					Gibbon::Request.lists(list_id).segments.create body: {
						name: "Stage-based static segment",
						static_segment: [subscriber_email]
					}
				}
				
				let(:body) {
					{
						type: 'regular',
						recipients: {
							list_id: list_id,
							segment_opts: { saved_segment_id: segment['id'] }
						},
						settings: {
							folder_id: mailchimp_folder_ids[:parent_newsletters_campaigns],
							title: title,
							subject_line: title,
							from_name: 'Kinstantly',
							reply_to: 'kinstantly@kinstantly.com'
						}
					}
				}
				
				let(:subscription) {
					FactoryGirl.create :subscription, email: subscriber_email
				}
				
				let(:subscription_stage) {
					FactoryGirl.create :subscription_stage, title: title, list_id: list_id
				}
				
				let(:subscription_delivery) {
					FactoryGirl.create :subscription_delivery, {
						subscription: subscription,
						subscription_stage: subscription_stage,
						email: subscription.email,
						source_campaign_id: subscription_stage.source_campaign_id,
						campaign_id: campaign['id'],
						send_time: nil
					}
				}
				
				it "should update the send_time in the campaign's subscription_delivery records" do
					subscription_delivery # schedule for delivery
					
					expect {
						post :process_notification, campaign_params
					}.to change {
						subscription_delivery.reload.send_time
					}.from(nil).to(Time.zone.parse campaign['send_time'])
				end
				
				it "should not archive a stage-based campaign" do
					expect {
						post :process_notification, campaign_params
					}.to_not change(Newsletter, :count)
				end
			end
		end
	end
end
