require 'spec_helper'

describe Customer do
	let(:customer) { FactoryGirl.create :customer }
	let(:parent) { FactoryGirl.create :parent }
	let(:profile) { FactoryGirl.create :claimed_profile }
	let(:provider) { profile.user }
	let(:stripe_token) { 'tok_14dHeE2wVg10iFMK9gYM2T72' }
	let(:authorized_amount) { 1000 }
	
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
	
	it "should create a customer and card" do
		pending 'stubs of Stripe::Customer.create and Stripe::Charge.create'
		customer.save_with_authorization(
			user:         parent,
			profile_id:   profile.id,
			stripe_token: stripe_token,
			amount:       authorized_amount
		)
	end
end
