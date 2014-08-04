require 'spec_helper'

describe ContactBlocker do
	let(:contact_blocker) { FactoryGirl.build :contact_blocker }
	let(:contact_blocker_with_email_delivery) { FactoryGirl.build :contact_blocker_with_email_delivery }
	
	it "has an email address" do
		contact_blocker.email = 'junior_brown@example.org'
		contact_blocker.should have(:no).errors_on(:email)
	end
	
	it "validates the email address" do
		contact_blocker.email = 'junior_brown@example'
		contact_blocker.should have(1).error_on(:email)
	end
	
	it "can be associated with an email delivery" do
		contact_blocker.email_delivery = FactoryGirl.create :email_delivery
		contact_blocker.should have(:no).errors_on(:email_delivery)
	end
	
	it "updates from given attribute values" do
		email = 'junior_brown@example.org'
		expect {
			contact_blocker.update_attributes_from_email_delivery email: email
		}.to change(ContactBlocker, :count).by(1)
		ContactBlocker.find_by_email(email).should be_present
	end
	
	it "blocks both the recipient of an email delivery and the given email address" do
		recipient = contact_blocker_with_email_delivery.email_delivery.recipient
		given_email = 'Other'+recipient
		expect {
			contact_blocker_with_email_delivery.update_attributes_from_email_delivery email: given_email
		}.to change(ContactBlocker, :count).by(2)
		ContactBlocker.find_by_email(given_email).should be_present
		ContactBlocker.find_by_email(recipient).should be_present
	end
	
	it "will not create duplicate records" do
		email = 'junior_brown@example.org'
		expect {
			contact_blocker.update_attributes_from_email_delivery email: email
			contact_blocker.update_attributes_from_email_delivery email: email
		}.to change(ContactBlocker, :count).by(1)
	end
	
	it "will not create duplicate records based on the email delivery" do
		given_email = 'Other'+contact_blocker_with_email_delivery.email_delivery.recipient
		expect {
			contact_blocker_with_email_delivery.update_attributes_from_email_delivery email: given_email
			contact_blocker_with_email_delivery.update_attributes_from_email_delivery email: given_email
		}.to change(ContactBlocker, :count).by(2)
	end
end
