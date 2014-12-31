require 'spec_helper'

describe StripeCharge, payments: true do
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
	
	it "should generate an error if the refund amount is too large" do
		charge = FactoryGirl.build :stripe_charge, amount_usd: '10.00', refund_amount_usd: '20.00'
		charge.valid?(:create_refund).should be_false
		charge.errors[:refund_amount].should be_present
	end
	
	it "should generate an error if the refund reason is not valid" do
		charge = FactoryGirl.build :stripe_charge, amount_usd: '40.00', refund_amount_usd: '20.00', refund_reason: 'whatever'
		charge.valid?(:create_refund).should be_false
		charge.errors[:refund_reason].should be_present
	end
	
	context "using the Stripe API" do
		let(:charge_amount_usd) { '200.00' }
		let(:charge_amount_cents) { (charge_amount_usd.to_f * 100).to_i }
		let(:charge_fee_cents) { (charge_amount_cents * 0.05).to_i }
		
		let(:api_balance_transaction) {
			transaction = double('Stripe::BalanceTransaction').as_null_object
			transaction.stub fee: charge_fee_cents, fee_details: []
			transaction
		}
		let(:api_refund) {
			refund = double('Stripe::Refund').as_null_object
			refund.stub balance_transaction: api_balance_transaction, created: 1419075210
			refund
		}
		let(:api_refunds) {
			Struct.new 'StripeRefunds' unless defined? Struct::StripeRefunds
			refunds = double('Struct::StripeRefunds').as_null_object
			refunds.stub(:create) do |refund_arguments, access_token|
				@amount_refunded = refund_arguments[:amount]
				api_refund
			end
			refunds
		}
		let(:api_charge) { 
			charge = double('Stripe::Charge').as_null_object
			charge.stub refunds: api_refunds
			charge.stub(:amount_refunded) { @amount_refunded }
			charge
		}
		let(:api_application_fee_list) {
			list = double('Stripe::ListObject').as_null_object
			list.stub data: []
			list
		}
		
		before(:each) do
			Stripe::Charge.stub(:retrieve).with(any_args) do
				api_charge
			end
			Stripe::BalanceTransaction.stub(:retrieve).with(any_args) do
				api_balance_transaction
			end
			Stripe::ApplicationFee.stub(:all).with(any_args) do
				api_application_fee_list
			end
		end
		
		context "perform refunds" do
			let(:refund_amount_usd) { '25.00' }
			let(:refund_amount_cents) { (refund_amount_usd.to_f * 100).to_i }
			let(:excessive_refund_amount_usd) { '400.00' }
			let(:charge_for_refund) {
				FactoryGirl.create :captured_stripe_charge_with_customer, amount_usd: charge_amount_usd
			}
		
			it "should perform a partial refund" do
				charge_for_refund.create_refund(refund_amount_usd: refund_amount_usd).should be_true
				charge_for_refund.reload
				charge_for_refund.amount_refunded.should == refund_amount_cents
			end
		
			it "should perform a full refund" do
				charge_for_refund.create_refund(refund_amount_usd: charge_amount_usd).should be_true
				charge_for_refund.reload
				charge_for_refund.amount_refunded.should == charge_amount_cents
			end
		
			it "should not refund more than the charge amount" do
				charge_for_refund.create_refund(refund_amount_usd: excessive_refund_amount_usd).should be_false
				charge_for_refund.reload
				charge_for_refund.amount_refunded.should be_nil
			end
		
			it "should generate an error if attempting to refund more than the charge amount" do
				charge_for_refund.create_refund(refund_amount_usd: excessive_refund_amount_usd).should be_false
				charge_for_refund.errors[:refund_amount].should be_present
			end
		
			it "should generate an error if refund amount is not specified" do
				charge_for_refund.create_refund(refund_amount_usd: nil).should be_false
				charge_for_refund.errors[:refund_amount].should be_present
			end
			
			it "should not allow a new refund on a fully refunded charge" do
				refunded_stripe_charge.create_refund(refund_amount_usd: refund_amount_usd).should be_false
				refunded_stripe_charge.errors.should_not be_empty
			end
			
			it "should allow multiple refunds on the same charge record" do
				charge_for_refund.create_refund(refund_amount_usd: refund_amount_usd).should be_true
				charge_for_refund.create_refund(refund_amount_usd: refund_amount_usd).should be_true
			end
			
			it "should not allow a refund greater that the remaining charge amount" do
				charge_for_refund.create_refund(refund_amount_usd: refund_amount_usd).should be_true
				charge_for_refund.create_refund(refund_amount_usd: charge_amount_usd).should be_false
				charge_for_refund.errors[:refund_amount].should be_present
			end
		end
	end
	
	context "Without valid Stripe API keys" do
		let(:charge_amount_usd) { '200.00' }
		let(:charge_for_refund) {
			FactoryGirl.create :captured_stripe_charge_with_customer, amount_usd: charge_amount_usd
		}
		
		before(:each) do
			Stripe::Charge.stub(:retrieve).and_raise(Stripe::AuthenticationError)
			Stripe::BalanceTransaction.stub(:retrieve).and_raise(Stripe::AuthenticationError)
			Stripe::ApplicationFee.stub(:all).and_raise(Stripe::AuthenticationError)
		end
		
		it "should not be able to perform a refund" do
			charge_for_refund.create_refund(refund_amount_usd: charge_amount_usd).should be_false
			charge_for_refund.reload
			charge_for_refund.amount_refunded.should be_nil
			charge_for_refund.errors.should_not be_empty
		end
	end
end
