require 'spec_helper'

describe StripeCharge, type: :model, payments: true do
	let(:new_stripe_charge) { FactoryGirl.build :stripe_charge }
	let(:new_stripe_charge_with_customer) { FactoryGirl.build :stripe_charge_with_customer }
	let(:stripe_charge) { FactoryGirl.create :stripe_charge }
	let(:captured_stripe_charge) { FactoryGirl.create :captured_stripe_charge }
	let(:uncaptured_stripe_charge) { FactoryGirl.create :uncaptured_stripe_charge }
	let(:refunded_stripe_charge) { FactoryGirl.create :refunded_stripe_charge }
	let(:partially_refunded_stripe_charge) { FactoryGirl.create :partially_refunded_stripe_charge }
	
	it "has an API ID" do
		expect(stripe_charge.api_charge_id).to be_present
	end
	
	it "has a charge amount" do
		expect(captured_stripe_charge.amount).to be > 0
		expect(captured_stripe_charge.paid).to be_truthy
	end
	
	it "can be captured" do
		expect(captured_stripe_charge.captured).to be_truthy
	end
	
	it "can be uncaptured" do
		expect(uncaptured_stripe_charge.captured).to be_falsey
	end
	
	it "can be refunded" do
		expect(refunded_stripe_charge.amount_refunded).to be > 0
		expect(refunded_stripe_charge.refunded).to be_truthy
	end
	
	it "can be partially refunded" do
		expect(partially_refunded_stripe_charge.amount_refunded).to be < partially_refunded_stripe_charge.amount
		expect(partially_refunded_stripe_charge.refunded).to be_falsey
	end
	
	it "notifies the customer of a new charge" do
		expect(new_stripe_charge).to receive :notify_customer
		new_stripe_charge.save
	end
	
	it "should deliver a notification when a charge is created with a customer" do
		expect(StripeChargeMailer).to receive(:notify_customer).and_return(double('Mail::Message').as_null_object)
		new_stripe_charge_with_customer.save
	end
	
	it "should not deliver a notification when a charge record is created without a customer" do
		expect(StripeChargeMailer).not_to receive(:notify_customer)
		new_stripe_charge.save
	end
	
	it "should generate an error if the refund amount is too large" do
		charge = FactoryGirl.build :stripe_charge, amount_usd: '10.00', refund_amount_usd: '20.00'
		expect(charge.valid?(:create_refund)).to be_falsey
		expect(charge.errors[:refund_amount]).to be_present
	end
	
	it "should generate an error if the refund reason is not valid" do
		charge = FactoryGirl.build :stripe_charge, amount_usd: '40.00', refund_amount_usd: '20.00', refund_reason: 'whatever'
		expect(charge.valid?(:create_refund)).to be_falsey
		expect(charge.errors[:refund_reason]).to be_present
	end
	
	it 'can be selected by provider' do
		customer_file = FactoryGirl.create :customer_file
		expect {
			captured_stripe_charge.customer_file = customer_file
			captured_stripe_charge.save
		}.to change {
			StripeCharge.all_for_provider(customer_file.provider).include?(captured_stripe_charge)
		}.from(false).to(true)
	end
	
	it 'can be ordered by most recent first' do
		stripe_charge # Create a charge.
		expect {
			new_stripe_charge.save
		}.to change {
			StripeCharge.most_recent_first.first
		}.from(stripe_charge).to(new_stripe_charge)
	end
	
	context "using the Stripe API" do
		let(:charge_amount_usd) { '200.00' }
		let(:charge_amount_cents) { (charge_amount_usd.to_f * 100).to_i }
		let(:charge_fee_cents) { (charge_amount_cents * 0.05).to_i }
		
		let(:api_balance_transaction) { stripe_balance_transaction_mock fee_cents: charge_fee_cents }
		let(:api_refund) { stripe_refund_mock balance_transaction: api_balance_transaction }
		let(:api_refunds) { stripe_charge_refunds_mock refund_mock: api_refund }
		let(:api_charge) { stripe_charge_mock amount_cents: charge_amount_cents,  refunds: api_refunds }
		let(:api_application_fee_list) { application_fee_list_mock }
		
		before(:example) do
			allow(Stripe::Charge).to receive(:retrieve).with(any_args) do
				api_charge
			end
			allow(Stripe::BalanceTransaction).to receive(:retrieve).with(any_args) do
				api_balance_transaction
			end
			allow(Stripe::ApplicationFee).to receive(:all).with(any_args) do
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
				expect(charge_for_refund.create_refund(refund_amount_usd: refund_amount_usd)).to be_truthy
				charge_for_refund.reload
				expect(charge_for_refund.amount_refunded).to eq refund_amount_cents
			end
		
			it "should perform a full refund" do
				expect(charge_for_refund.create_refund(refund_amount_usd: charge_amount_usd)).to be_truthy
				charge_for_refund.reload
				expect(charge_for_refund.amount_refunded).to eq charge_amount_cents
			end
		
			it "should not refund more than the charge amount" do
				expect(charge_for_refund.create_refund(refund_amount_usd: excessive_refund_amount_usd)).to be_falsey
				charge_for_refund.reload
				expect(charge_for_refund.amount_refunded).to be_nil
			end
		
			it "should generate an error if attempting to refund more than the charge amount" do
				expect(charge_for_refund.create_refund(refund_amount_usd: excessive_refund_amount_usd)).to be_falsey
				expect(charge_for_refund.errors[:refund_amount]).to be_present
			end
		
			it "should generate an error if refund amount is not specified" do
				expect(charge_for_refund.create_refund(refund_amount_usd: nil)).to be_falsey
				expect(charge_for_refund.errors[:refund_amount]).to be_present
			end
			
			it "should not allow a new refund on a fully refunded charge" do
				expect(refunded_stripe_charge.create_refund(refund_amount_usd: refund_amount_usd)).to be_falsey
				expect(refunded_stripe_charge.errors).not_to be_empty
			end
			
			it "should allow multiple refunds on the same charge record" do
				expect(charge_for_refund.create_refund(refund_amount_usd: refund_amount_usd)).to be_truthy
				expect(charge_for_refund.create_refund(refund_amount_usd: refund_amount_usd)).to be_truthy
			end
			
			it "should not allow a refund greater that the remaining charge amount" do
				expect(charge_for_refund.create_refund(refund_amount_usd: refund_amount_usd)).to be_truthy
				expect(charge_for_refund.create_refund(refund_amount_usd: charge_amount_usd)).to be_falsey
				expect(charge_for_refund.errors[:refund_amount]).to be_present
			end
		end
	end
	
	context "Without valid Stripe API keys" do
		let(:charge_amount_usd) { '200.00' }
		let(:charge_for_refund) {
			FactoryGirl.create :captured_stripe_charge_with_customer, amount_usd: charge_amount_usd
		}
		
		before(:example) do
			allow(Stripe::Charge).to receive(:retrieve).and_raise(Stripe::AuthenticationError)
			allow(Stripe::BalanceTransaction).to receive(:retrieve).and_raise(Stripe::AuthenticationError)
			allow(Stripe::ApplicationFee).to receive(:all).and_raise(Stripe::AuthenticationError)
		end
		
		it "should not be able to perform a refund" do
			expect(charge_for_refund.create_refund(refund_amount_usd: charge_amount_usd)).to be_falsey
			charge_for_refund.reload
			expect(charge_for_refund.amount_refunded).to be_nil
			expect(charge_for_refund.errors).not_to be_empty
		end
	end
end
