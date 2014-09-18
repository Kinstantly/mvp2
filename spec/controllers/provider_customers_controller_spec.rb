require 'spec_helper'

describe ProviderCustomersController do
	let(:parent) { FactoryGirl.create :parent }
	let(:stripe_token) { 'tok_14dHeE2wVg10iFMK9gYM2T72' }
	let(:email) { 'parent@example.com' }
	
	context "provider customer is not signed in" do
		describe "GET new" do
			it "is prevented by CanCan to assign a new provider_customer" do
				get :new
				assigns(:provider_customer).should be_nil
			end
		end

		describe "POST create" do
			it "is prevented by CanCan to create a provider customer record" do
				pending 'stub of ProviderCustomer#create_customer_with_card'
				expect {
					post :create, stripeToken: stripe_token, stripeEmail: email
				}.to change(ProviderCustomer, :count).by 0
			end
		end
	end
	
	context "provider customer is signed in" do
		before(:each) do
			sign_in parent
		end
		
		describe "GET new" do
			it "assigns a new provider_customer as @provider_customer" do
				get :new
				assigns(:provider_customer).should be_a_new(ProviderCustomer)
			end
		end

		describe "POST create" do
			it "creates a provider customer record" do
				pending 'stub of ProviderCustomer#create_customer_with_card'
				expect {
					post :create, stripeToken: stripe_token, stripeEmail: email
				}.to change(ProviderCustomer, :count).by 1
			end
		end
	end
end
