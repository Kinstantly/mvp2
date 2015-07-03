require 'spec_helper'

describe CustomersController, type: :controller, payments: true do
	let(:parent) { FactoryGirl.create :parent }
	let(:email) { 'parent@example.com' }
	let(:provider) { FactoryGirl.create :payable_provider }
	let(:profile) { provider.profile }
	let(:profile_id) { profile.id.to_s }
	let(:stripe_token) { 'tok_14dHeE2wVg10iFMK9gYM2T72' }
	let(:authorized_amount) { 1000 }

	let(:api_card) { stripe_card_mock }
	let(:api_customer) { stripe_customer_mock card: api_card }
	
	let(:invalid_provider) { FactoryGirl.create :provider_with_published_profile, email: 'invalid_provider@example.org' }
	let(:invalid_profile) { invalid_provider.profile }
	let(:invalid_profile_id) { invalid_profile.id.to_s }
	
	before(:each) do
		allow(Stripe::Customer).to receive(:create).with(any_args) do
			api_customer
		end
		allow(Stripe::Customer).to receive(:retrieve).with(any_args) do
			api_customer
		end
	end
	
	context "customer is not signed in" do
		describe "GET /authorize_payment/:profile_id" do
			it "is prevented by CanCan from assigning a new customer" do
				get :authorize_payment, profile_id: profile_id
				expect(assigns(:customer)).to be_nil
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
				expect(response).to redirect_to edit_user_registration_url
			end
			
			it "assigns a new customer as @customer" do
				get :authorize_payment, profile_id: profile_id
				expect(assigns(:customer)).to be_a_new(Customer)
			end

			it "assigns the provider's profile as @profile" do
				get :authorize_payment, profile_id: profile_id
				expect(assigns(:profile)).to eq profile
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
