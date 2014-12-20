require 'spec_helper'

describe CustomerFilesController, payments: true do
	let(:authorized_amount_cents) { 10000 }
	let(:charge_amount_usd) { '25.00' }
	let(:charge_amount_cents) { (charge_amount_usd.to_f * 100).to_i }
	let(:charge_fee_cents) { (charge_amount_cents * 0.05).to_i }
	let(:customer_file_1) { FactoryGirl.create :customer_file, authorized_amount: authorized_amount_cents }
	let(:provider) { customer_file_1.provider }
	let(:customer_file_2) { FactoryGirl.create :second_customer_file, provider: provider }
	let(:customer_1) { customer_file_1.customer }
	let(:parent_1) { customer_1.user }

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
	
	before(:each) do
		customer_file_1
		customer_file_2
		
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
		
	context "customer or provider is not signed in" do
		describe "GET new" do
			it "is prevented from viewing a list of customer files" do
				get :index
				response.status.should == 302 # Redirect.
				assigns(:customer_files).should be_nil
			end
		end

		describe "GET show" do
			it "is prevented from viewing a customer file" do
				get :show, id: customer_file_1.id
				response.status.should == 302 # Redirect.
				assigns(:customer_file).should be_nil
			end
		end
	end
	
	context "customer is signed in" do
		before(:each) do
			sign_in parent_1
		end
		
		describe "GET new" do
			it "assigns a list of the customer's files" do
				get :index
				assigns(:customer_files).include?(customer_file_1).should be_true
			end
			
			it "does not list another customer's file" do
				get :index
				assigns(:customer_files).include?(customer_file_2).should be_false
			end
		end

		describe "GET show" do
			it "assigns the customer's file" do
				get :show, id: customer_file_1.id
				assigns(:customer_file).should == customer_file_1
			end

			it "does not show another customer's file" do
				get :show, id: customer_file_2.id
				response.status.should == 302 # Redirect.
			end
		end
	end
	
	context "provider is signed in" do
		before(:each) do
			sign_in provider
		end
		
		describe "GET new" do
			it "assigns a list of the provider's customer files" do
				get :index
				assigns(:customer_files).include?(customer_file_1).should be_true
				assigns(:customer_files).include?(customer_file_2).should be_true
			end
		end

		describe "GET show" do
			it "assigns a customer file" do
				get :show, id: customer_file_1.id
				assigns(:customer_file).should == customer_file_1
			end
		end
		
		describe "GET new_charge" do
			it "assigns a customer file" do
				get :new_charge, id: customer_file_1.id
				assigns(:customer_file).should == customer_file_1
			end
		end
		
		describe "PUT create_charge" do
			it "creates a charge record" do
				expect {
					params = {
						charge_amount_usd: charge_amount_usd,
						charge_description: 'test',
						charge_statement_description: 'test'
					}
					put :create_charge, id: customer_file_1.id, customer_file: params
				}.to change(StripeCharge, :count).by(1)
			end
		end
	end
end
