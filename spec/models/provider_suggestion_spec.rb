require 'spec_helper'

describe ProviderSuggestion do
	let(:provider_suggestion) { FactoryGirl.create :provider_suggestion }
	let(:parent) { FactoryGirl.create :parent }
	
	it "can be associated with a suggester, e.g., a parent" do
		provider_suggestion.suggester = parent
		provider_suggestion.should have(:no).errors_on :suggester
	end
	
	context "required attributes" do
		it "must have a suggester or suggester fields" do
			provider_suggestion.suggester = nil
			provider_suggestion.suggester_email = nil
			provider_suggestion.should have(1).error_on :suggester
			provider_suggestion.should have(1).error_on :suggester_email
		end
		
		it "must have a provider name" do
			provider_suggestion.provider_name = nil
			provider_suggestion.should have(1).error_on :provider_name
		end
		
		it "must have a provider description" do
			provider_suggestion.description = nil
			provider_suggestion.should have(1).error_on :description
		end
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		[:description, :provider_name, :provider_url, :suggester_name].each do |attr|
			s = 'a' * ProviderSuggestion::MAX_LENGTHS[attr]
			provider_suggestion.send "#{attr}=", s
			provider_suggestion.should have(:no).errors_on(attr)
			provider_suggestion.send "#{attr}=", (s + 'a')
			provider_suggestion.should have(1).error_on(attr)
		end
	end
	
	it "must have a valid suggester email address if used" do
		provider_suggestion.suggester_email = 'invalid@example'
		provider_suggestion.should have(1).error_on :suggester_email
	end
end
