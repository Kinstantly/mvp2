require 'spec_helper'

describe CustomerFile do
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

	let(:api_token) { double('Stripe::Token').as_null_object }
	let(:api_charge) { 
		charge = double('Stripe::Charge').as_null_object
		charge.stub amount: charge_amount_cents
		charge
	}
	let(:api_balance_transaction) {
		transaction = double('Stripe::BalanceTransaction').as_null_object
		transaction.stub fee: charge_fee_cents, fee_details: []
		transaction
	}
		
	it "belongs to a provider" do
		customer_file.provider.should_not be_nil
	end
	
	it "references a customer" do
		customer_file.customer.should_not be_nil
	end
	
	it "specifies the amount authorized by the customer that the provider can charge" do
		customer_file.authorized_amount = 2500
		customer_file.should have(:no).errors_on(:authorized_amount)
	end
	
	context "Provider charging their customer" do
		before(:each) do
			Stripe::Token.stub(:create).with(any_args) do
				api_token
			end
			Stripe::Charge.stub(:create).with(any_args) do
				api_charge
			end
			Stripe::BalanceTransaction.stub(:retrieve).with(any_args) do
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
			customer_file.errors.should_not be_empty
		end
		
		it "should not allow a statement description that is too long" do
			expect {
				customer_file.create_charge charge_params.merge(charge_statement_description: 'Long statement description')
			}.to change(StripeCharge, :count).by(0)
			customer_file.errors.should_not be_empty
		end
	end
end
