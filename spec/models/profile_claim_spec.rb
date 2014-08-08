require 'spec_helper'

describe ProfileClaim do
	let(:profile_claim) { FactoryGirl.create :profile_claim }
	let(:parent) { FactoryGirl.create :parent }
	let(:profile) { FactoryGirl.create :profile }
	
	it "can be associated with a claimant, e.g., a parent" do
		profile_claim.claimant = parent
		profile_claim.should have(:no).errors_on :claimant
	end

	it "must be associated with a profile" do
		profile_claim.profile = nil
		profile_claim.should have(1).error_on :profile
	end
	
	context "required attributes" do
		it "must have a claimant email" do
			profile_claim.claimant_email = nil
			profile_claim.should have(1).error_on :claimant_email
		end
	end
	
	it "must have a valid claimant email address" do
		profile_claim.claimant_email = 'invalid@example'
		profile_claim.should have(1).error_on :claimant_email
	end

	it "must have a valid claimant phone if used" do
		profile_claim.claimant_phone = '123'
		profile_claim.should have(1).error_on :claimant_phone
	end
	
	context "protected attributes" do
		context "as default role" do
			it "can NOT mass-assign admin notes" do
				expect {
					profile_claim.update_attributes admin_notes: 'Bad notes.'
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end

			it "can NOT mass-assign claimant" do
				expect {
					profile_claim.update_attributes claimant_id: parent.to_param
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end

			it "can NOT mass-assign profile" do
				expect {
					profile_claim.update_attributes profile_id: profile.to_param
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end
		end
		
		context "as admin role" do
			let(:role) { {as: :admin} }
			
			it "can mass-assign admin notes" do
				expect {
					profile_claim.update_attributes({admin_notes: 'Good notes.'}, role)
				}.to_not raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end

			it "can NOT mass-assign claimant" do
				expect {
					profile_claim.update_attributes({claimant_id: parent.to_param}, role)
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end

			it "can NOT mass-assign profile" do
				expect {
					profile_claim.update_attributes profile_id: profile.to_param
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end
		end
	end
end
