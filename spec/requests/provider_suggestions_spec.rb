require 'spec_helper'

describe "ProviderSuggestions", :type => :request do
	
	# This should return at least the minimal set of attributes required to create a valid ProviderSuggestion.
	let (:valid_attributes) { FactoryGirl.attributes_for :provider_suggestion }
	
	describe "GET /provider_suggestions/new" do
		it "responds successfully" do
			get new_provider_suggestion_path
			expect(response.status).to eq(200)
		end
	end

	describe "POST /provider_suggestions" do
		it "responds successfully" do
			post provider_suggestions_path, provider_suggestion: valid_attributes
			expect(response.status).to eq(200)
		end
	end
	
	context "when running as a private site", private_site: true do
		describe "GET /provider_suggestions/new" do
			it "authorization fails" do
				get new_provider_suggestion_path
				expect(response.status).not_to eq(200)
			end
		end

		describe "POST /provider_suggestions" do
			it "responds successfully" do
				post provider_suggestions_path, provider_suggestion: valid_attributes
				expect(response.status).not_to eq(200)
			end
		end
	end
end
