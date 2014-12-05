require 'spec_helper'

describe StripeCharge do
	let(:new_stripe_charge) { FactoryGirl.build :stripe_charge }
	let(:new_stripe_charge_with_customer) { FactoryGirl.build :stripe_charge_with_customer }
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
	
	it "notifies the customer of a new charge" do
		new_stripe_charge.should_receive :notify_customer
		new_stripe_charge.save
	end
	
	it "should deliver a notification when a charge is created with a customer" do
		StripeChargeMailer.should_receive(:notify_customer).and_return(double('Mail::Message').as_null_object)
		new_stripe_charge_with_customer.save
	end
	
	it "should not deliver a notification when a charge record is created without a customer" do
		StripeChargeMailer.should_not_receive(:notify_customer)
		new_stripe_charge.save
	end
end
