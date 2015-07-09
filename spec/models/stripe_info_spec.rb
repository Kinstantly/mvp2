require 'spec_helper'

describe StripeInfo, type: :model, payments: true do
	let(:provider) { FactoryGirl.create :provider_before_payment_setup }
	let(:stripe_info) { FactoryGirl.build :stripe_info, user: provider }
	let(:stripe_user_id) { 'acct_15KNvdGsKLXicgHb' }
	let(:access_token) { 'sk_test_dwVGFg529pZw1DwZvrz7MWGb' }
	let(:publishable_key) { 'pk_test_75zFYVjHoaojFjW2fW4nCl7f' }
	let(:omniauth_values) {
		{
			uid:         stripe_user_id,
			info:        { stripe_publishable_key: publishable_key },
			credentials: { token: access_token },
			extra:       { raw_info: { stripe_publishable_key: publishable_key } }
		}
	}
	
	it "accepts authorization values" do
		expect(stripe_info.configure_authorization(omniauth_values)).to be_truthy
		expect(stripe_info.stripe_user_id).to eq stripe_user_id
		expect(stripe_info.access_token).to eq access_token
		expect(stripe_info.publishable_key).to eq publishable_key
	end
	
	it "sends a welcome email to a newly connected provider" do
		message = double('Mail::Message')
		expect(message).to receive :deliver
		expect(StripeConnectMailer).to receive(:welcome_provider).and_return(message)
		stripe_info.configure_authorization(omniauth_values)
	end
	
	it "creates a payment announcement" do
		stripe_info.configure_authorization(omniauth_values)
		expect(provider.profile.payment_profile_announcements.size).to eq 1
	end
	
	context "using the Stripe API" do
		let(:stripe_account) { stripe_account_mock }
		let(:stripe_account_pending_verification) { stripe_account_mock verified: false }
	
		it "needs more verification" do
			allow(Stripe::Account).to receive(:retrieve).with(any_args) do
				stripe_account_pending_verification
			end
			
			expect(stripe_info).not_to be_fully_enabled
		end
	
		it "is fully enabled" do
			allow(Stripe::Account).to receive(:retrieve).with(any_args) do
				stripe_account
			end
			
			expect(stripe_info).to be_fully_enabled
		end
	end
end
