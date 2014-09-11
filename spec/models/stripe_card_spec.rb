require 'spec_helper'

describe StripeCard do
	let(:stripe_card) { FactoryGirl.create :stripe_card }
	
	it "has an API ID" do
		stripe_card.api_card_id.should be_present
	end
	
	it "can have a charge" do
		expect {
			stripe_card.stripe_charges << FactoryGirl.create(:stripe_charge)
		}.to change { stripe_card.stripe_charges.size }.by(1)
	end
	
	it "can have multiple charges" do
		expect {
			stripe_card.stripe_charges << FactoryGirl.create(:stripe_charge)
			stripe_card.stripe_charges << FactoryGirl.create(:stripe_charge)
		}.to change { stripe_card.stripe_charges.size }.by(2)
	end
end
