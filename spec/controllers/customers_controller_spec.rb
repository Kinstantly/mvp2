require 'spec_helper'

describe CustomersController do
	let(:parent) { FactoryGirl.create :parent }
	let(:email) { 'parent@example.com' }
	let(:provider) { FactoryGirl.create :payable_provider }
	let(:profile) { provider.profile }
	let(:profile_id) { profile.id.to_s }
	let(:stripe_token) { 'tok_14dHeE2wVg10iFMK9gYM2T72' }
	let(:authorized_amount) { 1000 }

	let(:api_card) {
		card = double('Stripe::Card').as_null_object
		card.stub exp_month: 1, exp_year: 2050
		card
	}
	let(:api_customer) {
		customer = double('Stripe::Customer').as_null_object
		cards = double('Hash')
		cards.stub(:retrieve).with(any_args) { api_card }
		customer.stub cards: cards
		customer
	}
	
	let(:invalid_provider) { FactoryGirl.create :provider_with_published_profile, email: 'invalid_provider@example.org' }
	let(:invalid_profile) { invalid_provider.profile }
	let(:invalid_profile_id) { invalid_profile.id.to_s }
	
	before(:each) do
		Stripe::Customer.stub(:create).with(any_args) do
			api_customer
		end
		Stripe::Customer.stub(:retrieve).with(any_args) do
			api_customer
		end
	end
	
	context "customer is not signed in" do
		describe "GET /authorize_payment/:profile_id" do
			it "is prevented by CanCan from assigning a new customer" do
				get :authorize_payment, profile_id: profile_id
				assigns(:customer).should be_nil
			end
		end

		describe "POST create" do
			it "is prevented by CanCan from creating a customer record" do
				expect {
					post :create, profile_id: profile_id, stripeToken: stripe_token, authorized_amount: authorized_amount
				}.to change(Customer, :count).by 0
			end
		end
	end
	
	context "customer is signed in" do
		before(:each) do
			sign_in parent
		end
		
		describe "GET /authorize_payment/:profile_id" do
			it "requires provider to be set up for payment to be authorized" do
				get :authorize_payment, profile_id: invalid_profile_id
				response.should redirect_to edit_user_registration_url
			end
			
			it "assigns a new customer as @customer" do
				get :authorize_payment, profile_id: profile_id
				assigns(:customer).should be_a_new(Customer)
			end

			it "assigns the provider's profile as @profile" do
				get :authorize_payment, profile_id: profile_id
				assigns(:profile).should == profile
			end
		end

		describe "POST create" do
			it "creates a customer record" do
				expect {
					post :create, profile_id: profile_id, stripeToken: stripe_token, authorized_amount: authorized_amount
				}.to change(Customer, :count).by 1
			end
		end
	end
end
