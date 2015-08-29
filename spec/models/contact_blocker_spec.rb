require 'spec_helper'

describe ContactBlocker, :type => :model do
	let(:contact_blocker) { FactoryGirl.build :contact_blocker }
	let(:contact_blocker_with_email_delivery) { FactoryGirl.build :contact_blocker_with_email_delivery }
	let(:user) { FactoryGirl.build :parent, email: 'test_subscriber@kinstantly.com' }
	
	it "has an email address" do
		contact_blocker.email = 'junior_brown@example.org'
		contact_blocker.valid?
		expect(contact_blocker.errors[:email].size).to eq 0
	end
	
	it "validates the email address" do
		contact_blocker.email = 'junior_brown@example'
		contact_blocker.valid?
		expect(contact_blocker.errors[:email].size).to eq 1
	end
	
	it "can be associated with an email delivery" do
		contact_blocker.email_delivery = FactoryGirl.create :email_delivery
		contact_blocker.valid?
		expect(contact_blocker.errors[:email_delivery].size).to eq 0
	end
	
	it "updates from given attribute values" do
		email = 'junior_brown@example.org'
		expect {
			contact_blocker.update_attributes_from_email_delivery email: email
		}.to change(ContactBlocker, :count).by(1)
		expect(ContactBlocker.find_by_email(email)).to be_present
	end
	
	it "blocks both the recipient of an email delivery and the given email address" do
		recipient = contact_blocker_with_email_delivery.email_delivery.recipient
		given_email = 'Other'+recipient
		expect {
			contact_blocker_with_email_delivery.update_attributes_from_email_delivery email: given_email
		}.to change(ContactBlocker, :count).by(2)
		expect(ContactBlocker.find_by_email(given_email)).to be_present
		expect(ContactBlocker.find_by_email(recipient)).to be_present
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
			expect(contact_blocker).to receive :remove_email_subscriptions
			contact_blocker.email = 'junior_brown@example.org'
			contact_blocker.save
		end
		
		context "after creating subscriptions" do
			before(:example) do
				user.parent_newsletters = true
				user.provider_newsletters = true
				user.save
			end
			
			it "has created subscriptions for testing purposes" do
				user.reload
				expect(user.parent_newsletters).to be_truthy
				expect(user.provider_newsletters).to be_truthy
				expect(user.parent_newsletters_leid).not_to be_nil
				expect(user.provider_newsletters_leid).not_to be_nil
			end
			
			context "after the contact blocker for the user's email address is saved" do
				before(:example) do
					contact_blocker.email = user.email
					contact_blocker.save
				end
				
				it "has removed existing subscriptions" do
					user.reload
					expect(user.parent_newsletters).to be_falsey
					expect(user.provider_newsletters).to be_falsey
					expect(user.parent_newsletters_leid).to be_nil
					expect(user.provider_newsletters_leid).to be_nil
				end
			end
		end
	end
end
