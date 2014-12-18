require 'spec_helper'

describe StripeChargesController do
	let(:charge_without_provider) { FactoryGirl.create :captured_stripe_charge }
	let(:charge_without_customer) { FactoryGirl.create :captured_stripe_charge }
	let(:charge) { FactoryGirl.create :captured_stripe_charge_with_customer }
	let(:provider) { charge.customer_file.provider }
	let(:client) { charge.customer_file.customer_user }
	
	context "provider is not signed in" do
		describe "GET show" do
			it "cannot show the details of a charge" do
				get :show, id: charge.id
				response.status.should == 302 # Redirect.
				assigns(:stripe_charge).should be_nil # Never makes it to CanCan.
			end
		end
	end
	
	context "provider is signed in" do
		before(:each) do
			sign_in provider
		end
		
		describe "GET show" do
			it "can ONLY show the details of a charge made by the provider" do
				get :show, id: charge_without_provider.id
				response.status.should == 302 # Redirect.
			end
		end
		
		describe "GET show" do
			it "shows the details of a charge made by the provider" do
				get :show, id: charge.id
				assigns(:stripe_charge).should == charge
			end
		end
		
		context "using the Stripe API" do
			let(:charge_amount_usd) { '200.00' }
			let(:charge_amount_cents) { (charge_amount_usd.to_f * 100).to_i }
			let(:charge_fee_cents) { (charge_amount_cents * 0.05).to_i }
			let(:refund_amount_usd) { '25.00' }
			let(:refund_amount_cents) { (refund_amount_usd.to_f * 100).to_i }
			
			let(:api_balance_transaction) {
				transaction = double('Stripe::BalanceTransaction').as_null_object
				transaction.stub fee: charge_fee_cents, fee_details: []
				transaction
			}
			let(:api_refund) {
				refund = double('Stripe::Refund').as_null_object
				refund.stub balance_transaction: api_balance_transaction
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
				
				charge.amount_usd = charge_amount_usd
				charge.save
			end
			
			describe "PUT create_refund" do
				it "applies a partial refund" do
					put :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: refund_amount_usd}
					assigns(:stripe_charge).amount_refunded_usd.cents.should == refund_amount_cents
				end

				it "applies a full refund" do
					put :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: charge_amount_usd}
					assigns(:stripe_charge).amount_refunded_usd.cents.should == charge_amount_cents
				end
			
				it "cannot refund more than the charge" do
					put :create_refund, id: charge.id, stripe_charge: {refund_amount_usd: '$400.00'}
					response.should render_template :show
					assigns(:stripe_charge).amount_refunded_usd.should be_nil
				end
			end
		end
	end
	
	context "client is not signed in" do
		describe "GET show" do
			it "cannot show the details of a charge" do
				get :show, id: charge.id
				response.status.should == 302 # Redirect.
				assigns(:stripe_charge).should be_nil # Never makes it to CanCan.
			end
		end
	end
	
	context "client is signed in" do
		before(:each) do
			sign_in client
		end
		
		describe "GET show" do
			it "can ONLY show the details of a charge made to the client" do
				get :show, id: charge_without_customer.id
				response.status.should == 302 # Redirect.
			end
		end
		
		describe "GET show" do
			it "shows the details of a charge made to the client" do
				get :show, id: charge.id
				assigns(:stripe_charge).should == charge
			end
		end
	end
end
