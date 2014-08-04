require 'spec_helper'

describe "ContactBlockers" do
	let (:valid_attributes) { FactoryGirl.attributes_for :contact_blocker }
	let(:email_delivery) { FactoryGirl.create :email_delivery }
	
	describe "request unsubscribe form" do
		it "responds successfully" do
			get new_contact_blocker_from_email_delivery_path(email_delivery_token: email_delivery.token)
			response.status.should eq(200)
		end
	end

	describe "submit unsubscribe form" do
		it "responds successfully" do
			post create_contact_blocker_from_email_delivery_path(email_delivery_token: email_delivery.token), contact_blocker: valid_attributes
			response.status.should eq(302)
			response.redirect_url.should == contact_blocker_confirmation_url
		end
	end
end
