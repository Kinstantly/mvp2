require 'spec_helper'

describe ProviderSuggestion, :type => :model do
	let(:provider_suggestion) { FactoryGirl.create :provider_suggestion }
	let(:parent) { FactoryGirl.create :parent }
	
	it "can be associated with a suggester, e.g., a parent" do
		provider_suggestion.suggester = parent
		provider_suggestion.valid?
		expect(provider_suggestion.errors[:suggester].size).to eq 0
	end
	
	context "required attributes" do
		it "must have a suggester or suggester fields" do
			provider_suggestion.suggester = nil
			provider_suggestion.suggester_email = nil
			expect(provider_suggestion.error_on(:suggester_email).size).to eq 1
		end
		
		it "must have a provider name" do
			provider_suggestion.provider_name = nil
			expect(provider_suggestion.error_on(:provider_name).size).to eq 1
		end
		
		it "must have a provider description" do
			provider_suggestion.description = nil
			expect(provider_suggestion.error_on(:description).size).to eq 1
		end
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		[:description, :provider_name, :provider_url, :suggester_name].each do |attr|
			s = 'a' * ProviderSuggestion::MAX_LENGTHS[attr]
			provider_suggestion.send "#{attr}=", s
			expect(provider_suggestion.errors_on(attr).size).to eq 0
			provider_suggestion.send "#{attr}=", (s + 'a')
			expect(provider_suggestion.error_on(attr).size).to eq 1
		end
	end
	
	it "must have a valid suggester email address if used" do
		provider_suggestion.suggester_email = 'invalid@example'
		expect(provider_suggestion.error_on(:suggester_email).size).to eq 1
	end
	
	context "protected attributes" do
		context "as default role" do
			it "can NOT mass-assign admin notes" do
				expect {
					provider_suggestion.update_attributes admin_notes: 'Bad notes.'
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end

			it "can NOT mass-assign suggester" do
				expect {
					provider_suggestion.update_attributes suggester_id: parent.to_param
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end
		end
		
		context "as admin role" do
			let(:role) { {as: :admin} }
			
			it "can mass-assign admin notes" do
				expect {
					provider_suggestion.update_attributes({admin_notes: 'Good notes.'}, role)
				}.to_not raise_error
			end

			it "can NOT mass-assign suggester" do
				expect {
					provider_suggestion.update_attributes({suggester_id: parent.to_param}, role)
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end
		end
	end
end
