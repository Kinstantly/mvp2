require 'spec_helper'

describe ProviderCustomer do
	let(:provider_customer) { FactoryGirl.create :provider_customer }
	let(:parent) { FactoryGirl.create :parent }
	let(:stripe_token) { 'tok_14dHeE2wVg10iFMK9gYM2T72' }
	let(:authorization_amount) { 1000 }
	
	it "should be associated with a user, e.g., a parent" do
		provider_customer.user = parent
		provider_customer.should have(:no).errors_on :user
	end
	
	it "should be associated with a provider" do
		provider_customer.provider = provider
		provider_customer.should have(:no).errors_on :provider
	end
	
	context "required attributes" do
		it "must have a user" do
			provider_customer.user = nil
			provider_customer.should have(1).error_on :user
		end
	end
	
	it "should create a customer and card" do
		pending 'stubs of Stripe::Customer.create and Stripe::Charge.create'
		provider_customer.create_customer_with_card(
			user:         parent,
			stripe_token: stripe_token,
			amount:       authorization_amount
		)
	end
end
