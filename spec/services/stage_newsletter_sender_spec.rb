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
			
			let(:date_format) { '%-m/%-d/%Y' }
			let(:now) { Time.zone.now }
			let(:member_emails) {
				[
					'subscriber_1@kinstantly.com',
					'subscriber_2@kinstantly.com',
					'subscriber_3@kinstantly.com'
				]
			}
			let(:members) {
				hash = {}
				member_emails.each_index do |i|
					hash[member_emails[i]] = [(now - (stages[titles[i]] + 1).days), nil, nil, nil]
				end
				hash
			}
			
			let(:create_subscriptions) {
				members.each do |email, birthdates|
					Gibbon::Request.lists(list_id).members.create(body: {
						email_address: email,
						status: 'subscribed',
						merge_fields: {
							'DUEBIRTH1' => birthdates.first.try(:strftime, date_format),
							'BIRTH2' => birthdates.second.try(:strftime, date_format),
							'BIRTH3' => birthdates.third.try(:strftime, date_format),
							'BIRTH4' => birthdates.fourth.try(:strftime, date_format)
						}
					})
				end
				
				response = Gibbon::Request.lists(list_id).members.retrieve params: { count: (members.size + 1) }
				subscribed_members = response['members']
				subscribed_emails = subscribed_members.map { |member| member['email_address'] }
				expect(subscribed_emails.sort).to eq member_emails.sort
				
				expect {
					list_importer = MailchimpListImporter.new list: list
					list_importer.call
				}.to change(Subscription, :count).by(members.size)
				
				subscribed_members
			}
			
			let(:create_stages) {
				source_campaigns = titles.map do |title|
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
				
				source_campaigns
			}
			
			it 'should send stages with eligible subscribers' do
				create_subscriptions
				create_stages
				
				newsletter_sender.call
				
				expect(newsletter_sender).to be_successful
				expect(newsletter_sender.errors).to be_blank
			end
			
			it 'should create a scheduled campaign for each stage to send' do
				create_subscriptions
				create_stages
				
				expect {
					newsletter_sender.call
				}.to change {
					# scheduled and sent campaigns
					Gibbon::Request.campaigns.retrieve(params: {
						folder_id: sent_folder_id
					})['campaigns'].size
				}.by members.size
				
				Gibbon::Request.campaigns.
				retrieve(params: { folder_id: sent_folder_id })['campaigns'].each do |campaign|
					expect(campaign['status']).to eq 'schedule'
					expect(campaign['send_time']).to be_present
				end
			end
			
			it 'should log delivery to each recipient' do
				create_subscriptions
				create_stages
				
				newsletter_sender.call
				
				member_emails.each_index do |i|
					stage = SubscriptionStage.find_by_title titles[i]
					email = member_emails[i]
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
			
			context 'with many recipients' do
				# override member_emails and members; they are used by the setup procedures
				let(:n_members) { 102 }
				let(:member_emails) {
					(1..n_members).inject([]) do |emails, i|
						emails << "subscriber_#{i}@kinstantly.com"
					end
				}
				let(:members) {
					days_since_birth = now - (stages[titles[0]] + 2).days
					
					member_emails.inject({}) do |members_hash, email|
						members_hash[email] = [days_since_birth]
						members_hash
					end
				}
				
				it 'should successfully schedule, then use multiple batches to retrieve the scheduled members' do
					# use a smallish batch size to test multi-batch retrieval
					newsletter_sender_params[:batch_size] = 10
					
					create_subscriptions
					create_stages
				
					expect {
						newsletter_sender.call
					}.to change(SubscriptionDelivery, :count).by n_members
				end
			end
			
			context 'with recipients that have multiple children' do
				# array of days since birth for each stage
				let(:days_since_birth) {
					(0..2).inject([]) do |days, i|
						days << (stages[titles[i]] + 1).days
					end
				}
				
				# override member_emails and members; they are used by the setup procedures
				let(:member_emails) {
					(1..4).inject([]) do |emails, i|
						emails << "subscriber_#{i}@kinstantly.com"
					end
				}
				# seed with members that should receive a stage based on the second, third, or fourth child
				let(:members) {
					members_hash = {}
					members_hash[member_emails[0]] = [
						now + 30.days, now - days_since_birth[0]
					]
					members_hash[member_emails[1]] = [
						now + 30.days, nil, now - days_since_birth[1]
					]
					members_hash[member_emails[2]] = [
						now + 30.days, nil, nil, now - days_since_birth[2]
					]
					members_hash[member_emails[3]] = [
						now + 30.days, now - days_since_birth[0], now - days_since_birth[1]
					]
					members_hash
				}
				
				it "should use any of the children's birth dates for recipient selection" do
					create_subscriptions
					create_stages
				
					expect {
						newsletter_sender.call
					}.to change(SubscriptionDelivery, :count).by 5
				
					stage_delivery_count = SubscriptionDelivery.where({
						subscription_stage: SubscriptionStage.find_by_title(titles[0])
					}).count
					expect(stage_delivery_count).to eq 2
				
					stage_delivery_count = SubscriptionDelivery.where({
						subscription_stage: SubscriptionStage.find_by_title(titles[1])
					}).count
					expect(stage_delivery_count).to eq 2
				
					stage_delivery_count = SubscriptionDelivery.where({
						subscription_stage: SubscriptionStage.find_by_title(titles[2])
					}).count
					expect(stage_delivery_count).to eq 1
				end
			end
			
			it 'should not send duplicates' do
				create_subscriptions
				create_stages
				
				# first call should schedule recipients for delivery
				expect {
					StageNewsletterSender.new(newsletter_sender_params).call
				}.to change(SubscriptionDelivery, :count).by members.size
				
				# duplicate supression should prevent second call from scheduling recipients
				expect {
					StageNewsletterSender.new(newsletter_sender_params).call
				}.not_to change(SubscriptionDelivery, :count)
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
		
		it 'should specify a proper batch size if used' do
			sender = StageNewsletterSender.new(newsletter_sender_params.merge batch_size: 0)
			sender.call
			expect(sender.errors).to be_present
		end
	end
end
