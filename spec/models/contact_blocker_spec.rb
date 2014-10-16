require 'spec_helper'

describe ContactBlocker do
	let(:contact_blocker) { FactoryGirl.build :contact_blocker }
	let(:contact_blocker_with_email_delivery) { FactoryGirl.build :contact_blocker_with_email_delivery }
	let(:user) { FactoryGirl.build :parent, email: 'test_subscriber@kinstantly.com' }
	
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
	
	context "removes existing mailing list subscriptions" do
		it "checks for subscriptions" do
			contact_blocker.should_receive :remove_email_subscriptions
			contact_blocker.email = 'junior_brown@example.org'
			contact_blocker.save
		end
		
		context "after creating subscriptions" do
			before(:each) do
				user.parent_marketing_emails = true
				user.parent_newsletters = true
				user.provider_marketing_emails = true
				user.provider_newsletters = true
				user.save
			end
			
			it "has created subscriptions for testing purposes" do
				user.reload
				user.parent_marketing_emails.should be_true
				user.parent_newsletters.should be_true
				user.provider_marketing_emails.should be_true
				user.provider_newsletters.should be_true
				user.subscriber_euid.should_not be_nil
				user.subscriber_leid.should_not be_nil
			end
			
			context "after the contact blocker for the user's email address is saved" do
				before(:each) do
					contact_blocker.email = user.email
					contact_blocker.save
				end
				
				it "has removed existing subscriptions" do
					user.reload
					user.parent_marketing_emails.should be_false
					user.parent_newsletters.should be_false
					user.provider_marketing_emails.should be_false
					user.provider_newsletters.should be_false
					user.subscriber_euid.should be_nil
					user.subscriber_leid.should be_nil
				end
			end
		end
	end
end
