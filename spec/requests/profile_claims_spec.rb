require 'spec_helper'

describe "ProfileClaims" do
	let (:valid_attributes) { FactoryGirl.attributes_for :profile_claim }
	
	describe "GET /profile_claims/new" do
		it "responds successfully" do
			get new_profile_claim_path
			response.status.should eq(200)
		end
	end

	describe "POST /profile_claims" do
		it "responds successfully" do
			post profile_claims_path, profile_claim: valid_attributes
			response.status.should eq(200)
		end
	end
	
	context "when running as a private site", private_site: true do
		describe "GET /profile_claims/new" do
			it "authorization fails" do
				get new_profile_claim_path
				response.status.should_not eq(200)
			end
		end

		describe "POST /profile_claims" do
			it "responds successfully" do
				post profile_claims_path, profile_claim: valid_attributes
				response.status.should_not eq(200)
			end
		end
	end
end
