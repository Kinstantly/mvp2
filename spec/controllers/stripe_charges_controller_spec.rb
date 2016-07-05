require 'spec_helper'

describe StripeChargesController, type: :controller, payments: true do
	let(:charge_without_provider) { FactoryGirl.create :captured_stripe_charge }
	let(:charge_without_customer) { FactoryGirl.create :captured_stripe_charge }
	let(:charge) { FactoryGirl.create :captured_stripe_charge_with_customer }
	let(:provider) { charge.customer_file.provider }
	let(:client) { charge.customer_file.customer_user }
	
	context "provider is not signed in" do
		describe "GET show" do
			it "cannot show the details of a charge" do
				get :show, id: charge.id
				expect(response.status).to eq 302 # Redirect.
				expect(assigns(:stripe_charge)).to be_nil # Never makes it to CanCan.
			end
		end
	end
	
	context "provider is signed in" do
		before(:example) do
			sign_in provider
		end
		
		describe "GET show" do
			it "can ONLY show the details of a charge made by the provider" do
				get :show, id: charge_without_provider.id
				expect(response.status).to eq 302 # Redirect.
			end
		end
		
		describe "GET show" do
			it "shows the details of a charge made by the provider" do
				get :show, id: charge.id
				expect(assigns(:stripe_charge)).to eq charge
			end
		end
		
		context "using the Stripe API" do
			let(:charge_amount_usd) { '200.00' }
			let(:charge_amount_cents) { (charge_amount_usd.to_f * 100).to_i }
			let(:charge_fee_cents) { (charge_amount_cents * 0.05).to_i }
			let(:refund_amount_usd) { '25.00' }
			let(:refund_amount_cents) { (refund_amount_usd.to_f * 100).to_i }
			
			let(:api_balance_transaction) { stripe_balance_transaction_mock fee_cents: charge_fee_cents }
			let(:api_refund) { stripe_refund_mock balance_transaction: api_balance_transaction }
			let(:api_refunds) { stripe_charge_refunds_mock refund_mock: api_refund }
			let(:api_charge) { stripe_charge_mock amount: charge_amount_cents, refunds: api_refunds }
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
				
				charge.amount_usd = charge_amount_usd
				charge.save
			end
			
			describe "PATCH create_refund" do
				it "applies a partial refund" do
					patch :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: refund_amount_usd}
					expect(assigns(:stripe_charge).amount_refunded_usd.cents).to eq refund_amount_cents
				end

				it "applies a full refund" do
					patch :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: charge_amount_usd}
					expect(assigns(:stripe_charge).amount_refunded_usd.cents).to eq charge_amount_cents
				end
				
				it "applies multiple refunds" do
					patch :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: refund_amount_usd}
					patch :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: refund_amount_usd}
					expect(assigns(:stripe_charge).amount_refunded_usd.cents).to eq(2 * refund_amount_cents)
				end
			
				it "cannot refund more than the charge" do
					patch :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: '$400.00'}
					expect(response).to render_template :show
					expect(assigns(:stripe_charge).amount_refunded_usd).to be_nil
				end
			
				it "cannot do multiple refunds totalling more than the charge" do
					patch :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: refund_amount_usd}
					patch :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: charge_amount_usd}
					expect(response).to render_template :show
					expect(assigns(:stripe_charge).amount_refunded_usd.cents).to eq refund_amount_cents
				end
			end
		end
	end
	
	context "client is not signed in" do
		describe "GET show" do
			it "cannot show the details of a charge" do
				get :show, id: charge.id
				expect(response.status).to eq 302 # Redirect.
				expect(assigns(:stripe_charge)).to be_nil # Never makes it to CanCan.
			end
		end
	end
	
	context "client is signed in" do
		before(:example) do
			sign_in client
		end
		
		describe "GET show" do
			it "can ONLY show the details of a charge made to the client" do
				get :show, id: charge_without_customer.id
				expect(response.status).to eq 302 # Redirect.
			end
		end
		
		describe "GET show" do
			it "shows the details of a charge made to the client" do
				get :show, id: charge.id
				expect(assigns(:stripe_charge)).to eq charge
			end
		end
	end
end
