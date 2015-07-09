require 'spec_helper'

describe "ContactBlockers", :type => :request do
	let (:valid_attributes) { FactoryGirl.attributes_for :contact_blocker }
	let(:email_delivery) { FactoryGirl.create :email_delivery }
	
	describe "request unsubscribe form" do
		it "responds successfully" do
			get new_contact_blocker_from_email_delivery_path(email_delivery_token: email_delivery.token)
			expect(response.status).to eq(200)
		end
	end

	describe "submit unsubscribe form" do
		it "responds successfully" do
			post create_contact_blocker_from_email_delivery_path(email_delivery_token: email_delivery.token), contact_blocker: valid_attributes
			expect(response.status).to eq(302)
			expect(response.redirect_url).to eq contact_blocker_confirmation_url
		end
	end
end
