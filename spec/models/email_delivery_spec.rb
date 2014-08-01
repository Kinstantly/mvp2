require 'spec_helper'

describe EmailDelivery do
	let(:email_delivery) { FactoryGirl.build :email_delivery }
	
	it "has a recipient" do
		email_delivery.recipient = 'astor_piazzolla@example.org'
		email_delivery.should have(:no).errors_on(:recipient)
	end
	
	it "has a sender" do
		email_delivery.sender = 'user:1'
		email_delivery.should have(:no).errors_on(:user)
	end
	
	it "has an email type" do
		email_delivery.email_type = 'invitation'
		email_delivery.should have(:no).errors_on(:email_type)
	end
	
	it "has a unique token" do
		email_delivery.token = UUIDTools::UUID.timestamp_create.to_s
		email_delivery.should have(:no).errors_on(:token)
	end
	
	it "has a tracking category" do
		email_delivery.tracking_category = 'profile_claim'
		email_delivery.should have(:no).errors_on(:tracking_category)
	end
	
	it "can be associated with a profile" do
		email_delivery.profile = FactoryGirl.create :profile
		email_delivery.should have(:no).errors_on(:profile)
	end
end
