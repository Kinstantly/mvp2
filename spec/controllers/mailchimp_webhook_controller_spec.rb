require 'spec_helper'

describe MailchimpWebhookController, type: :controller, mailchimp: true do
	let(:fired_at) {
		# MailChimp doesn't explicitly specify the time zone for this parameter. :(
		Time.now.utc.to_s.sub(' UTC', '')
	} 
	let(:token) { Rails.configuration.mailchimp_webhook_security_token }
	let(:list_id) { mailchimp_list_ids[:parent_newsletters]}
	let(:subscriber_email) { 'subscriber_1@kinstantly.com' }
	let(:user) { FactoryGirl.create(:client_user, email: subscriber_email) }
	let(:params) {
		{
			type: "unsubscribe",
			token: token,
			fired_at: fired_at,
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
				
				# Unsubscribe without deleting user from the list
				email_hash = email_md5_hash user.email
				Gibbon::Request.lists(list_id).members(email_hash).update body: {
					status: 'unsubscribed'
				}
			end

			it "should not process notification without a valid token" do
				expect {
					params[:token] = "none"
					post :process_notification, params
				}.not_to change {
					user.reload.parent_newsletters
				}
			end

			it "should not process notification with invalid request params" do
				expect {
					params.delete(:type)
					post :process_notification, params
				}.not_to change {
					user.reload.parent_newsletters
				}
			end
			
			it 'should not process notification if list_id is suspicious' do
				expect {
					params[:data][:list_id] = 'foo;bar'
					post :process_notification, params
				}.not_to change {
					user.reload.parent_newsletters
				}
			end
			
			it 'should not process notification if list_id is wrong' do
				expect {
					params[:data][:list_id] = 'foo'
					post :process_notification, params
				}.not_to change {
					user.reload.parent_newsletters
				}
			end
			
			it 'should not process notification if email is suspicious' do
				expect {
					params[:data][:email] = 'foo;bar'
					post :process_notification, params
				}.not_to change {
					user.reload.parent_newsletters
				}
			end
			
			it 'should not process notification if email is wrong' do
				expect {
					params[:data][:email] = 'foo'
					post :process_notification, params
				}.not_to change {
					user.reload.parent_newsletters
				}
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
		
		context 'user unsubscribed remotely with no local user account' do
			let(:email_hash) { email_md5_hash subscriber_email }
			let(:member) {
				Gibbon::Request.lists(list_id).members(email_hash).upsert body: {
					email_address: subscriber_email,
					status: 'unsubscribed'
				}
			}
			# Before each example:
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
		
		context 'subscriber email address changed' do
			let(:email_hash) { email_md5_hash subscriber_email }
			let(:member) {
				Gibbon::Request.lists(list_id).members(email_hash).upsert body: {
					email_address: subscriber_email,
					status: 'subscribed'
				}
			}
			# Before each example:
			let!(:subscription) {
				FactoryGirl.create :subscription, {
					list_id: list_id,
					email: subscriber_email,
					subscriber_hash: member['id'],
					unique_email_id: member['unique_email_id'],
					status: member['status']
				}
			}
			
			let(:new_subscriber_email) { "new_#{subscriber_email}" }
			let(:member_after_email_change) {
				Gibbon::Request.lists(list_id).members(email_hash).update body: {
					email_address: new_subscriber_email
				}
			}
			let(:upemail_params) {
				{
					type: 'upemail',
					token: token,
					fired_at: fired_at,
					data: {
						list_id: list_id,
						new_id: member_after_email_change['unique_email_id'],
						new_email: new_subscriber_email,
						old_email: subscriber_email
					}
				}
			}
			
			it 'should update email address in subscription record' do
				expect {
					post :process_notification, upemail_params
				}.to change {
					subscription.reload.email
				}.from(subscriber_email).to(new_subscriber_email)
			end
			
			it 'should update unique_email_id in subscription record' do
				expect {
					post :process_notification, upemail_params
				}.to change {
					subscription.reload.unique_email_id
				}.from(member['unique_email_id']).to(member_after_email_change['unique_email_id'])
			end
			
			it 'should update subscriber_hash in subscription record' do
				expect {
					post :process_notification, upemail_params
				}.to change {
					subscription.reload.subscriber_hash
				}.from(member['id']).to(member_after_email_change['id'])
			end
			
			it 'should not update subscription record if list_id is suspicious' do
				expect {
					upemail_params[:data][:list_id] = 'foo;bar'
					post :process_notification, upemail_params
				}.not_to change {
					subscription.reload.email
				}
			end
			
			it 'should not update subscription record if list_id is wrong' do
				expect {
					upemail_params[:data][:list_id] = 'foo'
					post :process_notification, upemail_params
				}.not_to change {
					subscription.reload.email
				}
			end
			
			it 'should not update subscription record if new email address is bad' do
				expect {
					upemail_params[:data][:new_email] = 'foo'
					post :process_notification, upemail_params
				}.not_to change {
					subscription.reload.email
				}
			end
			
			it 'should not update subscription record if old email address is bad' do
				expect {
					upemail_params[:data][:old_email] = 'foo'
					post :process_notification, upemail_params
				}.not_to change {
					subscription.reload.email
				}
			end
			
			it 'should not update subscription record if new_id is suspicious' do
				expect {
					upemail_params[:data][:new_id] = 'foo;bar'
					post :process_notification, upemail_params
				}.not_to change {
					subscription.reload.email
				}
			end
			
			context 'subscriber has a user account' do
				# Before each example:
				let!(:user) {
					FactoryGirl.create(:client_user, email: subscriber_email, parent_newsletters: true)
				}
				
				it 'should update the leid (unique_email_id) value of the user account' do
					expect {
						post :process_notification, upemail_params
					}.to change {
						user.reload.leid :parent_newsletters
					}.from(member['unique_email_id']).to(member_after_email_change['unique_email_id'])
				end
				
				it 'should not change the email address of the user account' do
					expect {
						post :process_notification, upemail_params
					}.not_to change {
						user.reload.email
					}
				end
			end
		end
		
		context 'someone subscribed' do
			let(:email_hash) { email_md5_hash subscriber_email }
			
			let(:member) {
				Gibbon::Request.lists(list_id).members(email_hash).upsert body: {
					email_address: subscriber_email,
					status: 'subscribed',
					email_type: 'html',
					merge_fields: {
						'DUEBIRTH1' => '3/20/2017'
					}
				}
			}
			
			let(:subscribe_params) {
				{
					type: 'subscribe',
					token: token,
					fired_at: fired_at,
					data: {
						list_id: list_id,
						id: "#{member['unique_email_id']}",
						email: "#{member['email_address']}",
						email_type: "#{member['email_type']}",
						merges: {
							"EMAIL" => "#{member['email_address']}",
							"FNAME" => "#{member['merge_fields']['FNAME']}",
							"LNAME" => "#{member['merge_fields']['LNAME']}",
							"DUEBIRTH1" => "#{member['merge_fields']['DUEBIRTH1']}",
							"BIRTH2" => "#{member['merge_fields']['BIRTH2']}",
							"BIRTH3" => "#{member['merge_fields']['BIRTH3']}",
							"BIRTH4" => "#{member['merge_fields']['BIRTH4']}",
							"ZIPCODE" => "#{member['merge_fields']['ZIPCODE']}",
							"POSTALCODE" => "#{member['merge_fields']['POSTALCODE']}",
							"COUNTRY" => "#{member['merge_fields']['COUNTRY']}",
							"SUBSOURCE" => "#{member['merge_fields']['SUBSOURCE']}"
						}
					}
				}
			}
			
			it 'should create a subscription record' do
				expect {
					post :process_notification, subscribe_params
				}.to change(Subscription, :count).by 1
			end
			
			it 'should save the merge data' do
				post :process_notification, subscribe_params
				subscription = Subscription.where(list_id: list_id, email: subscriber_email).take
				expect(subscription.birth1.to_s).to eq subscribe_params[:data][:merges]['DUEBIRTH1']
			end
			
			it 'should not create subscription record if list_id is suspicious' do
				expect {
					subscribe_params[:data][:list_id] = 'foo;bar'
					post :process_notification, subscribe_params
				}.not_to change(Subscription, :count)
			end
			
			it 'should not create subscription record if list_id is wrong' do
				expect {
					subscribe_params[:data][:list_id] = 'foo'
					post :process_notification, subscribe_params
				}.not_to change(Subscription, :count)
			end
			
			it 'should not create subscription record if email is suspicious' do
				expect {
					subscribe_params[:data][:email] = 'foo;bar'
					post :process_notification, subscribe_params
				}.not_to change(Subscription, :count)
			end
			
			it 'should not create subscription record if email is bad' do
				expect {
					subscribe_params[:data][:email] = 'foo'
					post :process_notification, subscribe_params
				}.not_to change(Subscription, :count)
			end
			
			it 'should not create a subscription record if member status is not "subscribed"' do
				expect {
					member # Set up member first.
					Gibbon::Request.lists(list_id).members(email_hash).update body: {
						status: 'pending'
					}
					post :process_notification, subscribe_params
				}.not_to change(Subscription, :count)
			end
			
			context 'a record already exists from a previous subscription' do
				let(:previous_subscription) {
					FactoryGirl.create(:subscription, {
						status: 'unsubscribed',
						list_id: list_id,
						email: subscriber_email,
						subscriber_hash: email_hash,
						unique_email_id: "#{member['unique_email_id']}",
						birth1: '2015-02-18'
					})
				}
				
				it 'should update the subscription status' do
					expect {
						post :process_notification, subscribe_params
					}.to change {
						previous_subscription.reload.subscribed
					}.from(false).to(true)
				end
			
				it 'should update merge data' do
					expect {
						post :process_notification, subscribe_params
					}.to change {
						previous_subscription.reload.birth1.to_s
					}.from(previous_subscription.birth1.to_s).to(subscribe_params[:data][:merges]['DUEBIRTH1'])
				end
			end
			
			context 'subscriber has a user account' do
				# Before each example:
				let!(:user) {
					FactoryGirl.create :client_user, {
						email: subscriber_email,
						parent_newsletters: false,
						parent_newsletters_leid: nil
					}
				}
				
				it 'should mark the user account as subscribed to the list' do
					expect {
						post :process_notification, subscribe_params
					}.to change {
						user.reload.parent_newsletters
					}.from(false).to(true)
				end
				
				it 'should update the leid (unique_email_id) value of the user account' do
					expect {
						post :process_notification, subscribe_params
					}.to change {
						user.reload.leid :parent_newsletters
					}.from(nil).to(member['unique_email_id'])
				end
			end
		end
		
		context 'a subscriber updated their profile' do
			let(:email_hash) { email_md5_hash subscriber_email }
			
			let(:member) {
				Gibbon::Request.lists(list_id).members(email_hash).upsert body: {
					email_address: subscriber_email,
					status: 'subscribed',
					email_type: 'html',
					merge_fields: {
						'DUEBIRTH1' => '3/16/2017',
						'BIRTH2' => '8/21/2015',
						'BIRTH3' => '7/1/2012',
						'BIRTH4' => '6/12/2010',
						'FNAME' => 'Pierre',
						'LNAME' => 'Boulez',
						'ZIPCODE' => '94107',
						'POSTALCODE' => 'QC H3A 0G4',
						'COUNTRY' => 'CA'
					}
				}
			}
			
			let(:profile_params) {
				{
					type: 'profile',
					token: token,
					fired_at: fired_at,
					data: {
						list_id: list_id,
						id: "#{member['unique_email_id']}",
						email: "#{member['email_address']}",
						email_type: "#{member['email_type']}",
						merges: {
							"EMAIL" => "#{member['email_address']}",
							"FNAME" => "#{member['merge_fields']['FNAME']}",
							"LNAME" => "#{member['merge_fields']['LNAME']}",
							"DUEBIRTH1" => "#{member['merge_fields']['DUEBIRTH1']}",
							"BIRTH2" => "#{member['merge_fields']['BIRTH2']}",
							"BIRTH3" => "#{member['merge_fields']['BIRTH3']}",
							"BIRTH4" => "#{member['merge_fields']['BIRTH4']}",
							"ZIPCODE" => "#{member['merge_fields']['ZIPCODE']}",
							"POSTALCODE" => "#{member['merge_fields']['POSTALCODE']}",
							"COUNTRY" => "#{member['merge_fields']['COUNTRY']}",
							"SUBSOURCE" => "#{member['merge_fields']['SUBSOURCE']}"
						}
					}
				}
			}
			
			let(:subscription) {
				FactoryGirl.create(:subscription, {
					status: 'subscribed',
					list_id: list_id,
					email: subscriber_email,
					subscriber_hash: email_hash,
					unique_email_id: "#{member['unique_email_id']}",
					birth1: '2017-03-20',
					fname: 'Sam'
				})
			}
			
			it 'should update the due/birth date' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.birth1.try :to_s
				}.from(subscription.birth1.try :to_s).to(profile_params[:data][:merges]['DUEBIRTH1'])
			end
			
			it 'should update a second birth date' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.birth2.try :to_s
				}.from(subscription.birth2.try :to_s).to(profile_params[:data][:merges]['BIRTH2'])
			end
			
			it 'should update a third birth date' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.birth3.try :to_s
				}.from(subscription.birth3.try :to_s).to(profile_params[:data][:merges]['BIRTH3'])
			end
			
			it 'should update a fourth birth date' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.birth4.try :to_s
				}.from(subscription.birth4.try :to_s).to(profile_params[:data][:merges]['BIRTH4'])
			end
			
			it 'should update the first name' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.fname
				}.from(subscription.fname).to(profile_params[:data][:merges]['FNAME'])
			end
			
			it 'should update the last name' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.lname
				}.from(subscription.lname).to(profile_params[:data][:merges]['LNAME'])
			end
			
			it 'should update the zip code' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.zip_code
				}.from(subscription.zip_code).to(profile_params[:data][:merges]['ZIPCODE'])
			end
			
			it 'should update the postal code' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.postal_code
				}.from(subscription.postal_code).to(profile_params[:data][:merges]['POSTALCODE'])
			end
			
			it 'should update the country' do
				expect {
					post :process_notification, profile_params
				}.to change {
					subscription.reload.country
				}.from(subscription.country).to(profile_params[:data][:merges]['COUNTRY'])
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
					fired_at: fired_at,
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
			
			it "should do nothing when invalid data is provided" do
				expect {
					campaign_params[:data][:id] = nil
					post :process_notification, campaign_params
				}.not_to change(Newsletter, :count)
			end
			
			it "should do nothing when a suspicious ID is detected" do
				expect {
					campaign_params[:data][:id] = 'foo;bar'
					post :process_notification, campaign_params
				}.not_to change(Newsletter, :count)
			end
			
			it "should do nothing when an unknown ID is provided" do
				expect {
					campaign_params[:data][:id] = 'foo'
					post :process_notification, campaign_params
				}.not_to change(Newsletter, :count)
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
					
					# Assume UTC if the time zone is not specified by the fired_at parameter.
					time_sent = Time.use_zone('UTC') { Time.zone.parse campaign_params[:fired_at] }
					
					expect {
						post :process_notification, campaign_params
					}.to change {
						subscription_delivery.reload.send_time
					}.from(nil).to(time_sent)
				end
				
				it "should not archive a stage-based campaign" do
					expect {
						post :process_notification, campaign_params
					}.to_not change(Newsletter, :count)
				end
				
				it 'should not process notification with suspicious event time parameter' do
					expect {
						campaign_params[:fired_at] = 'foo;bar'
						post :process_notification, campaign_params
					}.not_to change {
						subscription_delivery.reload.send_time
					}
				end
				
				# The following requires gibbon mocks, e.g., tweaking the campaign status.
				context 'notification arrived while campaign is still sending', use_gibbon_mocks: true do
					before(:example) do
						subscription_delivery # schedule for delivery
						set_mocked_campaign_status campaign['id'], 'sending'
					end
					
					it "should update the send_time in the campaign's subscription_delivery records" do
						# Assume UTC if the time zone is not specified by the fired_at parameter.
						time_sent = Time.use_zone('UTC') { Time.zone.parse campaign_params[:fired_at] }
					
						expect {
							post :process_notification, campaign_params
						}.to change {
							subscription_delivery.reload.send_time
						}.from(nil).to(time_sent)
					end
				end
			end
		end
	end
end
