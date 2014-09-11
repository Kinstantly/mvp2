require 'spec_helper'

describe StripeCharge do
	let(:stripe_charge) { FactoryGirl.create :stripe_charge }
	let(:captured_stripe_charge) { FactoryGirl.create :captured_stripe_charge }
	let(:uncaptured_stripe_charge) { FactoryGirl.create :uncaptured_stripe_charge }
	let(:refunded_stripe_charge) { FactoryGirl.create :refunded_stripe_charge }
	let(:partially_refunded_stripe_charge) { FactoryGirl.create :partially_refunded_stripe_charge }
	
	it "has an API ID" do
		stripe_charge.api_charge_id.should be_present
	end
	
	it "has a charge amount" do
		captured_stripe_charge.amount.should be > 0
		captured_stripe_charge.paid.should be_true
	end
	
	it "can be captured" do
		captured_stripe_charge.captured.should be_true
	end
	
	it "can be uncaptured" do
		uncaptured_stripe_charge.captured.should be_false
	end
	
	it "can be refunded" do
		refunded_stripe_charge.amount_refunded.should be > 0
		refunded_stripe_charge.refunded.should be_true
	end
	
	it "can be partially refunded" do
		partially_refunded_stripe_charge.amount_refunded.should be < partially_refunded_stripe_charge.amount
		partially_refunded_stripe_charge.refunded.should be_false
	end
end
