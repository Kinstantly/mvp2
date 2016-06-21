require 'spec_helper'

describe CustomerFilesController, type: :controller, payments: true do
	let(:authorized_amount_cents) { 10000 }
	let(:charge_amount_usd) { '25.00' }
	let(:charge_amount_cents) { (charge_amount_usd.to_f * 100).to_i }
	let(:charge_fee_cents) { (charge_amount_cents * 0.05).to_i }
	let(:customer_file_1) { FactoryGirl.create :customer_file, authorized_amount: authorized_amount_cents }
	let(:provider) { customer_file_1.provider }
	let(:customer_file_2) { FactoryGirl.create :second_customer_file, provider: provider }
	let(:customer_1) { customer_file_1.customer }
	let(:parent_1) { customer_1.user }
	
	let(:another_provider) { FactoryGirl.create :payable_provider, email: 'another_provider@example.org' }
	let(:another_customer_file) { FactoryGirl.create :customer_file, provider: another_provider, customer: customer_1 }

	let(:api_token) { stripe_token_mock }
	let(:api_balance_transaction) { stripe_balance_transaction_mock fee_cents: charge_fee_cents }
	
	before(:example) do
		customer_file_1
		customer_file_2
		
		allow(Stripe::Token).to receive(:create).with(any_args) do
			api_token
		end
		allow(Stripe::Charge).to receive(:create).with(any_args) do |params, access_token|
			stripe_charge_mock params
		end
		allow(Stripe::BalanceTransaction).to receive(:retrieve).with(any_args) do
			api_balance_transaction
		end
	end
		
	context "customer or provider is not signed in" do
		describe "GET index" do
			it "is prevented from viewing a list of customer files" do
				get :index
				expect(response.status).to eq 302 # Redirect.
				expect(assigns(:customer_files)).to be_nil
			end
		end

		describe "GET show" do
			it "is prevented from viewing a customer file" do
				get :show, id: customer_file_1.id
				expect(response.status).to eq 302 # Redirect.
				expect(assigns(:customer_file)).to be_nil
			end
		end
	end
	
	context "customer is signed in" do
		before(:example) do
			sign_in parent_1
		end
		
		describe "GET index" do
			it "does not list the customer's file" do
				get :index
				expect(assigns(:customer_files).include?(customer_file_1)).to be_falsey
			end
			
			it "does not list another customer's file" do
				get :index
				expect(assigns(:customer_files).include?(customer_file_2)).to be_falsey
			end
		end

		describe "GET show" do
			it "does not show the customer's file" do
				get :show, id: customer_file_1.id
				expect(response.status).to eq 302 # Redirect.
			end

			it "does not show another customer's file" do
				get :show, id: customer_file_2.id
				expect(response.status).to eq 302 # Redirect.
			end
		end
	end
	
	context "provider is signed in" do
		before(:example) do
			sign_in provider
		end
		
		describe "GET index" do
			it "assigns a list of the provider's customer files" do
				get :index
				expect(assigns(:customer_files).include?(customer_file_1)).to be_truthy
				expect(assigns(:customer_files).include?(customer_file_2)).to be_truthy
			end
			
			it "does not list another provider's customer file" do
				get :index
				expect(assigns(:customer_files).include?(another_customer_file)).to be_falsey
			end
		end

		describe "GET show" do
			it "assigns a customer file" do
				get :show, id: customer_file_1.id
				expect(assigns(:customer_file)).to eq customer_file_1
			end
		end
		
		describe "GET new_charge" do
			it "assigns a customer file" do
				get :new_charge, id: customer_file_1.id
				expect(assigns(:customer_file)).to eq customer_file_1
			end
		end
		
		describe "PUT create_charge" do
			let(:params) {
				{
					charge_amount_usd: charge_amount_usd,
					charge_description: 'test',
					charge_statement_description: 'test'
				}
			}
			
			it "creates a charge record" do
				expect {
					put :create_charge, id: customer_file_1.id, customer_file: params
				}.to change(StripeCharge, :count).by(1)
			end
			
			it 'decrements the authorized amount by the charge amount' do
				expect {
					put :create_charge, id: customer_file_1.id, customer_file: params
				}.to change { customer_file_1.reload.authorized_amount }.by(- charge_amount_cents)
			end
			
			it 'cannot modify the authorized amount directly' do
				expect {
					put :create_charge, id: customer_file_1.id,
						customer_file: params.merge(authorized_amount: (2 * customer_file_1.authorized_amount))
				}.to change { customer_file_1.reload.authorized_amount }.by(- charge_amount_cents)
			end
		end
	end
end
