require 'spec_helper'

# Because these examples are scheduling campaigns, require mocks. Thus we won't send real emails.

describe StageNewsletterSender, mailchimp: true, use_gibbon_mocks: true do
	let(:list) { :parent_newsletters }
	let(:list_id) { mailchimp_list_ids[list] }
	let(:source_folder) { :parent_newsletters_source_campaigns }
	let(:source_folder_id) { mailchimp_folder_ids[source_folder] }
	let(:sent_folder) { :parent_newsletters_campaigns }
	let(:sent_folder_id) { mailchimp_folder_ids[sent_folder] }
	
	let(:newsletter_sender_params) { {
		list: list,
		folder: sent_folder
	} }
	let(:newsletter_sender) { StageNewsletterSender.new(newsletter_sender_params) }

	let(:newsletter_sender_error) {
		StageNewsletterSender.new(newsletter_sender_params.merge folder: nil)
	}
	
	context 'with valid parameters' do
		it 'should return success' do
			expect(newsletter_sender.call).to be_truthy
		end
	
		it 'should have a success status' do
			newsletter_sender.call
			expect(newsletter_sender).to be_successful
		end
		
		context 'select recipients and schedule delivery for each stage' do
			let(:stages) {
				{
					'Your Child is 3 YEARS, 1 month' => 1123,
					'Your Child is 3 YEARS, 2 months' => 1153,
					'Your Child is 3 YEARS, 3 months' => 1184
				}
			}
			let(:titles) { stages.keys.sort }
			let(:body) {
				{
					type: 'regular',
					settings: {
						folder_id: source_folder_id,
						title: titles[0],
						subject_line: titles[0],
						from_name: 'Kinstantly',
						reply_to: 'kinstantly@kinstantly.com'
					}
				}
			}
			
			let(:now) { Time.zone.now }
			let(:members) {
				{
					'subscriber1@kinstantly.com' => [(now - (stages[titles[0]] + 1).days)],
					'subscriber2@kinstantly.com' => [(now - (stages[titles[1]] + 1).days)]
				}
			}
			let(:member_emails) { members.keys.sort }
			
			it 'should send stages with eligible subscribers' do
				members.each do |email, birthdates|
					Gibbon::Request.lists(list_id).members.create(body: {
						email_address: email,
						status: 'subscribed',
						merge_fields: {
							'DUEBIRTH1' => birthdates[0].strftime('%-m/%-d/%Y')
						}
					})
				end
				
				subscribed_members = Gibbon::Request.lists(list_id).members.retrieve['members']
				subscribed_emails = subscribed_members.map { |member| member['email_address'] }
				expect(subscribed_emails.sort).to eq member_emails
				
				expect {
					list_importer = MailchimpListImporter.new list: list
					list_importer.call
				}.to change(Subscription, :count).by(members.size)
				
				titles.each do |title|
					body[:settings][:title] = body[:settings][:subject_line] = title
					Gibbon::Request.campaigns.create body: body
				end
			
				expect {
					stage_importer = SubscriptionStageImporter.new list: list, folder: source_folder
					stage_importer.call
				}.to change(SubscriptionStage, :count).by(stages.size)
				
				stages.each do |title, trigger_delay_days|
					stage = SubscriptionStage.find_by_title title
					stage.update trigger_delay_days: trigger_delay_days
				end
				
				newsletter_sender.call
				expect(newsletter_sender).to be_successful
				expect(newsletter_sender.errors).to be_blank
				
				scheduled_campaigns = Gibbon::Request.campaigns.retrieve(params: {
					folder_id: sent_folder_id
				})['campaigns']
				expect(scheduled_campaigns.size).to eq members.size
				
				scheduled_campaigns.each do |campaign|
					expect(campaign['status']).to eq 'schedule'
					expect(campaign['send_time']).to be_present
				end
				
				stage = SubscriptionStage.find_by_title titles[0]
				email = 'subscriber1@kinstantly.com'
				subscription = Subscription.find_by_email email
				delivery = SubscriptionDelivery.where(
					email: email,
					subscription: subscription,
					subscription_stage: stage,
					source_campaign_id: stage.source_campaign_id
				).first
				expect(delivery).to be_present
				
				stage = SubscriptionStage.find_by_title titles[1]
				email = 'subscriber2@kinstantly.com'
				subscription = Subscription.find_by_email email
				delivery = SubscriptionDelivery.where(
					email: email,
					subscription: subscription,
					subscription_stage: stage,
					source_campaign_id: stage.source_campaign_id
				).first
				expect(delivery).to be_present
			end
			
		end
	end
	
	context 'with invalid parameters' do
		it 'should not return success' do
			expect(newsletter_sender_error.call).to be_falsey
		end
	
		it 'should not have a success status' do
			newsletter_sender_error.call
			expect(newsletter_sender_error).not_to be_successful
		end
	end
end
