require 'spec_helper'

describe ProfileClaim, :type => :model do
	let(:profile_claim) { FactoryGirl.create :profile_claim }
	let(:parent) { FactoryGirl.create :parent }
	let(:profile) { FactoryGirl.create :profile }
	
	it 'can be ordered by descending ID' do
		id1 = (FactoryGirl.create :profile_claim).id
		id2 = (FactoryGirl.create :profile_claim).id
		expect(ProfileClaim.order_by_descending_id.first.id).to eq (id1 > id2 ? id1 : id2)
		expect(ProfileClaim.order_by_descending_id.last.id).to eq (id1 < id2 ? id1 : id2)
	end
	
	it "can be associated with a claimant, e.g., a parent" do
		profile_claim.claimant = parent
		profile_claim.valid?
		expect(profile_claim.errors[:claimant].size).to eq 0
	end

	it "must be associated with a profile" do
		profile_claim.profile = nil
		profile_claim.valid?
		expect(profile_claim.errors[:profile].size).to eq 1
	end
	
	context "required attributes" do
		it "must have a claimant email" do
			profile_claim.claimant_email = nil
			profile_claim.valid?
			expect(profile_claim.errors[:claimant_email].size).to eq 1
		end
	end
	
	it "must have a valid claimant email address" do
		profile_claim.claimant_email = 'invalid@example'
		profile_claim.valid?
		expect(profile_claim.errors[:claimant_email].size).to eq 1
	end

	it "must have a valid claimant phone if used" do
		profile_claim.claimant_phone = '123'
		profile_claim.valid?
		expect(profile_claim.errors[:claimant_phone].size).to eq 1
	end
end
