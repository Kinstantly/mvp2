require 'spec_helper'

RSpec.describe SubscriptionDelivery, type: :model, mailchimp: true do
	let(:new_subscription_delivery) { FactoryGirl.build :subscription_delivery }
	let(:new_subscription_stage) { FactoryGirl.build :subscription_stage }
	let(:new_subscription) { FactoryGirl.build :subscription }
	
	it 'has an email address' do
		email = 'new_email@kinstantly.com'
		
		expect {
			new_subscription_delivery.email = email
		}.to change {
			new_subscription_delivery.email
		}.from(new_subscription_delivery.email).to(email)
	end
	
	it 'references a SubscriptionStage' do
		expect {
			new_subscription_delivery.subscription_stage = new_subscription_stage
		}.to change { new_subscription_delivery.subscription_stage }.from(nil).to(new_subscription_stage)
	end
	
	it 'references a Subscription' do
		expect {
			new_subscription_delivery.subscription = new_subscription
		}.to change { new_subscription_delivery.subscription }.from(nil).to(new_subscription)
	end
	
	it 'identifies the source campaign from which the delivered campaign was replicated' do
		source_campaign_id = 'zaq1xsw2cde3'
		
		expect {
			new_subscription_delivery.source_campaign_id = source_campaign_id
		}.to change {
			new_subscription_delivery.source_campaign_id
		}.from(new_subscription_delivery.source_campaign_id).to(source_campaign_id)
	end
	
	it 'identifies the campaign that was delivered' do
		campaign_id = 'zaq1xsw2cde3'
		
		expect {
			new_subscription_delivery.campaign_id = campaign_id
		}.to change {
			new_subscription_delivery.campaign_id
		}.from(new_subscription_delivery.campaign_id).to(campaign_id)
	end
	
	it 'identifies the send time' do
		send_time = Time.zone.now
		
		expect {
			new_subscription_delivery.send_time = send_time
		}.to change {
			new_subscription_delivery.send_time
		}.from(new_subscription_delivery.send_time).to(send_time)
	end
	
end
