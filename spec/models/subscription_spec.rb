require 'spec_helper'

RSpec.describe Subscription, type: :model, mailchimp: true do
	let(:new_subscription) { FactoryGirl.build :subscription }
	
	it 'has an email address' do
		original_email = new_subscription.email
		new_email = 'new_email@kinstantly.com'
		
		expect {
			new_subscription.email = new_email
		}.to change { new_subscription.email }.from(original_email).to(new_email)
	end
	
	it 'syncs the "subscribed" property with the "status" property' do
		new_subscription.subscribed = false
		new_subscription.status = 'unsubscribed'
		expect {
			new_subscription.update status: 'subscribed'
		}.to change { new_subscription.subscribed }.from(false).to(true)
	end
	
	it 'syncs the "subscribed" property when unsubscribing' do
		new_subscription.subscribed = true
		new_subscription.status = 'subscribed'
		expect {
			new_subscription.update status: 'unsubscribed'
		}.to change { new_subscription.subscribed }.from(true).to(false)
	end
end
