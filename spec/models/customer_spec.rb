require 'spec_helper'

describe Customer, type: :model, payments: true do
	let(:customer) { FactoryGirl.create :customer }
	let(:parent) { FactoryGirl.create :parent }
	let(:provider) { FactoryGirl.create :payable_provider }
	let(:profile) { provider.profile }
	let(:profile_id) { profile.id.to_s }
	let(:stripe_token) { 'tok_14dHeE2wVg10iFMK9gYM2T72' }
	let(:authorized_amount) { 1000 } # USD
	let(:authorized_amount_cents) { authorized_amount * 100 }
	let(:authorization) {
		{
			user:         parent,
			profile_id:   profile.id,
			stripe_token: stripe_token,
			amount:       authorized_amount
		}
	}

	let(:api_customer) { stripe_customer_mock }

	let(:invalid_provider) { FactoryGirl.create :provider_with_published_profile, email: 'invalid_provider@example.org' }
	let(:invalid_profile) { invalid_provider.profile }
	let(:invalid_profile_id) { invalid_profile.id.to_s }
	let(:invalid_authorization) { authorization.merge profile_id: invalid_profile_id }
	
	it "should be associated with a user, e.g., a parent" do
		customer.user = parent
		customer.valid?
		expect(customer.errors[:user].size).to eq 0
	end
	
	it "should be associated with at least one provider" do
		customer.providers << provider
		customer.valid?
		expect(customer.errors[:providers].size).to eq 0
	end
	
	context "required attributes" do
		it "must have a user" do
			customer.user = nil
			customer.valid?
			expect(customer.errors[:user].size).to eq 1
		end
	end
	
	it "should not retrieve a provider that is not payable" do
		expect {
			customer.provider_for_profile(invalid_profile_id)
		}.to raise_error(Payment::ChargeAuthorizationError)
	end
	
	it "should retrieve a payable provider" do
		expect(customer.provider_for_profile(profile_id)).to eq provider
	end
		
	it "should not authorize a provider that is not payable" do
		customer.save_with_authorization invalid_authorization
		expect(customer.errors.size).to eq 1
	end
	
	context "new customer" do
		before(:example) do
			expect(Stripe::Customer).to receive(:create).and_return(api_customer)
			allow(Stripe::Customer).to receive(:retrieve).with(any_args) do
				api_customer
			end
		end
		
		it "should return the authorized amount for the given authorized provider" do
			customer.save_with_authorization authorization
			expect(customer.authorized_amount_for_profile(profile_id).cents).to eq authorized_amount_cents
		end
		
	  it "should create a customer record" do
			expect {
				customer.save_with_authorization authorization
			}.to change{StripeCustomer.count}.by(1)
		end
		
		it "should attach the new customer record" do
			customer.save_with_authorization authorization
			expect(customer.stripe_customer).not_to be_nil
		end
		
	  it "should create a card record" do
			expect {
				customer.save_with_authorization authorization
			}.to change{StripeCard.count}.by(1)
		end
		
		it "should attach the new card record" do
			customer.save_with_authorization authorization
			expect(customer.stripe_customer.stripe_cards.size).to be >= 1
		end
		
		it "should send confirmation to the new customer" do
			message = double('Mail::Message')
			expect(message).to receive :deliver_now
			expect(CustomerMailer).to receive(:confirm_authorized_amount).and_return(message)
			customer.save_with_authorization authorization
		end
	end
	
	context "revoke authorization" do
		let(:customer_file_with_authorization) {
			FactoryGirl.create :second_customer_file, authorized_amount: authorized_amount
		}
		let(:customer_with_authorization) { customer_file_with_authorization.customer }
		let(:authorized_provider) { customer_file_with_authorization.provider }
		let(:revocation) {
			{
				profile_id: authorized_provider.profile.id,
				authorized: false
			}
		}
		
		it "should revoke authorization for the provider" do
			expect {
				customer_with_authorization.save_with_authorization revocation
			}.to change{ customer_file_with_authorization.reload.authorized }.from(true).to(false)
		end
		
		it "should send confirmation of the revoked authorization" do
			message = double('Mail::Message')
			expect(message).to receive :deliver_now
			expect(CustomerMailer).to receive(:confirm_revoked_authorization).and_return(message)
			customer_with_authorization.save_with_authorization revocation
		end
	end
	
	context "Without valid Stripe API keys" do
		before(:example) do
			allow(Stripe::Customer).to receive(:create).and_raise(Stripe::AuthenticationError)
			allow(Stripe::Customer).to receive(:retrieve).and_raise(Stripe::AuthenticationError)
		end
		
		it "should not be able to create a stripe_customer record" do
			expect {
				customer.save_with_authorization authorization
			}.to change(StripeCustomer, :count).by(0)
			expect(customer.errors).to be_present
		end
	end
end
