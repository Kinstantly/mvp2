require 'spec_helper'

describe CustomersController do
	let(:parent) { FactoryGirl.create :parent }
	let(:stripe_token) { 'tok_14dHeE2wVg10iFMK9gYM2T72' }
	let(:email) { 'parent@example.com' }
	
	context "customer is not signed in" do
		describe "GET new" do
			it "is prevented by CanCan to assign a new customer" do
				get :new
				assigns(:customer).should be_nil
			end
		end

		describe "POST create" do
			it "is prevented by CanCan to create a customer record" do
				pending 'stub of Customer#save_with_authorization'
				expect {
					post :create, stripeToken: stripe_token, stripeEmail: email
				}.to change(Customer, :count).by 0
			end
		end
	end
	
	context "customer is signed in" do
		before(:each) do
			sign_in parent
		end
		
		describe "GET new" do
			it "assigns a new customer as @customer" do
				get :new
				assigns(:customer).should be_a_new(Customer)
			end
		end

		describe "POST create" do
			it "creates a customer record" do
				pending 'stub of Customer#save_with_authorization'
				expect {
					post :create, stripeToken: stripe_token, stripeEmail: email
				}.to change(Customer, :count).by 1
			end
		end
	end
end
