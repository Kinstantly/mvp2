require 'spec_helper'

describe Customer do
	let(:customer) { FactoryGirl.create :customer }
	let(:parent) { FactoryGirl.create :parent }
	let(:provider) { FactoryGirl.create :payable_provider }
	let(:profile) { provider.profile }
	let(:profile_id) { profile.id.to_s }
	let(:stripe_token) { 'tok_14dHeE2wVg10iFMK9gYM2T72' }
	let(:authorized_amount) { 1000 }
	let(:authorization) {
		{
			user:         parent,
			profile_id:   profile.id,
			stripe_token: stripe_token,
			amount:       authorized_amount
		}
	}

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
	let(:invalid_authorization) { authorization.merge profile_id: invalid_profile_id }
	
	before(:each) do
		Stripe::Customer.stub(:create).with(any_args) do
			api_customer
		end
		Stripe::Customer.stub(:retrieve).with(any_args) do
			api_customer
		end
	end
	
	it "should be associated with a user, e.g., a parent" do
		customer.user = parent
		customer.should have(:no).errors_on :user
	end
	
	it "should be associated with at least one provider" do
		customer.providers << provider
		customer.should have(:no).errors_on :providers
	end
	
	context "required attributes" do
		it "must have a user" do
			customer.user = nil
			customer.should have(1).error_on :user
		end
	end
	
	it "should not retrieve a provider that is not payable" do
		expect {
			customer.provider_for_profile(invalid_profile_id)
		}.to raise_error(Payment::ChargeAuthorizationError)
	end
	
	it "should retrieve a payable provider" do
		customer.provider_for_profile(profile_id).should == provider
	end
		
	it "should not authorize a provider that is not payable" do
		customer.save_with_authorization invalid_authorization
		customer.should have(1).error
	end
	
	context "new customer" do
		before(:each) do
			Stripe::Customer.should_receive(:create).and_return(api_customer)
		end
		
		it "should return the authorized amount for the given authorized provider" do
			customer.save_with_authorization authorization
			customer.authorized_amount_for_profile(profile_id).should == authorized_amount
		end
		
	  it "should create a customer record" do
			expect {
				customer.save_with_authorization authorization
			}.to change{StripeCustomer.count}.by(1)
		end
		
		it "should attach the new customer record" do
			customer.save_with_authorization authorization
			customer.stripe_customer.should_not be_nil
		end
		
	  it "should create a card record" do
			expect {
				customer.save_with_authorization authorization
			}.to change{StripeCard.count}.by(1)
		end
		
		it "should attach the new card record" do
			customer.save_with_authorization authorization
			customer.stripe_customer.should have_at_least(1).stripe_card
		end
	end
end
