require 'spec_helper'

describe StripeCard, payments: true do
	let(:stripe_card) { FactoryGirl.create :stripe_card }
	let(:stripe_card_with_no_customer) { FactoryGirl.create :stripe_card_with_no_customer }
	let(:stripe_customer_with_card) { FactoryGirl.create :stripe_customer_with_cards, card_count: 1 }
	let(:api_card) { stripe_card_mock }
	let(:api_customer) { stripe_customer_mock card: api_card }
	
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
	
	context "remote card information" do
		before(:each) do
		  Stripe::Customer.stub(:retrieve).with(any_args) do
				api_customer
			end
		end
		
		it "can retrieve remote card information if attached to a stripe customer" do
			stripe_customer_with_card.stripe_cards.first.retrieve.should == api_card
		end
		
		it "cannot retrieve remote card information if not attached to a stripe customer" do
			stripe_card_with_no_customer.retrieve.should be_nil
		end
	end
end
