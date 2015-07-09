require 'spec_helper'

describe EmailDelivery, :type => :model do
	let(:email_delivery) { FactoryGirl.build :email_delivery }
	
	it "has a recipient" do
		email_delivery.recipient = 'astor_piazzolla@example.org'
		expect(email_delivery.errors_on(:recipient).size).to eq 0
	end
	
	it "has a sender" do
		email_delivery.sender = 'user:1'
		expect(email_delivery.errors_on(:user).size).to eq 0
	end
	
	it "has an email type" do
		email_delivery.email_type = 'invitation'
		expect(email_delivery.errors_on(:email_type).size).to eq 0
	end
	
	it "has a unique token" do
		email_delivery.token = UUIDTools::UUID.timestamp_create.to_s
		expect(email_delivery.errors_on(:token).size).to eq 0
	end
	
	it "has a tracking category" do
		email_delivery.tracking_category = 'profile_claim'
		expect(email_delivery.errors_on(:tracking_category).size).to eq 0
	end
	
	it "can be associated with a profile" do
		email_delivery.profile = FactoryGirl.create :profile
		expect(email_delivery.errors_on(:profile).size).to eq 0
	end
end
