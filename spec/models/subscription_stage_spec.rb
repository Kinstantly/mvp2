require 'spec_helper'

RSpec.describe SubscriptionStage, type: :model, mailchimp: true do
	let(:new_subscription_stage) { FactoryGirl.build :subscription_stage }
	
	it 'has a title' do
		title = 'Title that identifies this stage'
		
		expect {
			new_subscription_stage.title = title
		}.to change {
			new_subscription_stage.title
		}.from(new_subscription_stage.title).to(title)
	end
	
	it 'has a source campaign' do
		source_campaign_id = 'zaq1xsw2cde3'
		
		expect {
			new_subscription_stage.source_campaign_id = source_campaign_id
		}.to change {
			new_subscription_stage.source_campaign_id
		}.from(new_subscription_stage.source_campaign_id).to(source_campaign_id)
	end
	
	it "defines the number of days after a child's birthdate to trigger delivery" do
		more_days = 30
		
		expect {
			new_subscription_stage.trigger_delay_days += more_days
		}.to change(new_subscription_stage, :trigger_delay_days).by(more_days)
	end
end
