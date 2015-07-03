require 'spec_helper'

describe CustomerFile, type: :model, payments: true do
	let(:authorized_amount_cents) { 10000 }
	let(:charge_amount_usd) { '25.00' }
	let(:charge_amount_cents) { (charge_amount_usd.to_f * 100).to_i }
	let(:charge_fee_cents) { (charge_amount_cents * 0.05).to_i }
	let(:excessive_charge_amount_usd) { ((authorized_amount_cents + 100) / 100.0).to_s }
	let(:customer_file) { FactoryGirl.create :customer_file, authorized_amount: authorized_amount_cents }
	
	let(:charge_params) {
		{
			charge_amount_usd: charge_amount_usd,
			charge_description: 'Description',
			charge_statement_description: 'Short desc' # limited to 15 characters
		}
	}

	let(:api_token) { stripe_token_mock }
	let(:api_charge) { stripe_charge_mock amount_cents: charge_amount_cents }
	let(:api_balance_transaction) { stripe_balance_transaction_mock fee_cents: charge_fee_cents }
		
	it "belongs to a provider" do
		expect(customer_file.provider).not_to be_nil
	end
	
	it "references a customer" do
		expect(customer_file.customer).not_to be_nil
	end
	
	it "specifies the amount authorized by the customer that the provider can charge" do
		customer_file.authorized_amount = 2500
		expect(customer_file.errors_on(:authorized_amount).size).to eq 0
	end
	
	context "Provider charging their customer" do
		before(:each) do
			allow(Stripe::Token).to receive(:create).with(any_args) do
				api_token
			end
			allow(Stripe::Charge).to receive(:create).with(any_args) do
				api_charge
			end
			allow(Stripe::BalanceTransaction).to receive(:retrieve).with(any_args) do
				api_balance_transaction
			end
		end
		
		it "should create a charge" do
			expect {
				customer_file.create_charge charge_params
			}.to change(StripeCharge, :count).by(1)
		end
		
		it "should add the charge to this customer's list" do
			expect {
				customer_file.create_charge charge_params
			}.to change{customer_file.stripe_charges.count}.by(1)
		end
		
		it "should not allow a charge more than the authorized amount" do
			expect {
				customer_file.create_charge charge_params.merge(charge_amount_usd: excessive_charge_amount_usd)
			}.to change(StripeCharge, :count).by(0)
			expect(customer_file.errors).not_to be_empty
		end
		
		it "should not allow a statement description that is too long" do
			expect {
				customer_file.create_charge charge_params.merge(charge_statement_description: 'Long statement description')
			}.to change(StripeCharge, :count).by(0)
			expect(customer_file.errors).not_to be_empty
		end
	end
	
	context "Without valid Stripe API keys" do
		before(:each) do
			allow(Stripe::Token).to receive(:create).and_raise(Stripe::AuthenticationError)
			allow(Stripe::Charge).to receive(:create).and_raise(Stripe::AuthenticationError)
			allow(Stripe::BalanceTransaction).to receive(:retrieve).and_raise(Stripe::AuthenticationError)
		end
		
		it "should not be able to create a charge" do
			expect {
				customer_file.create_charge charge_params
			}.to change(StripeCharge, :count).by(0)
			expect(customer_file.errors).not_to be_empty
		end
	end
end
