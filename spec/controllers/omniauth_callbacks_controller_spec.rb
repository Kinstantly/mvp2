require 'spec_helper'

describe OmniauthCallbacksController, type: :controller, payments: true do
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
	
	context "using the Stripe API" do
		let(:stripe_account) { stripe_account_mock }
		let(:stripe_account_pending_verification) { stripe_account_mock verified: false }
	
		before(:each) do
		  sign_in provider
			@request.env["devise.mapping"] = Devise.mappings[:user] # This controller is an extension of a Devise controller.
			@request.env["omniauth.auth"] = omniauth_values
		end
		
		context "the new Stripe account is fully enabled" do
			it "completes the Stripe Connect setup" do
				allow(Stripe::Account).to receive(:retrieve).with(any_args) do
					stripe_account
				end
				get :stripe_connect
				expect(response).to render_template 'success'
			end
		end
		
		context "the new Stripe account is enabled but needs more verification" do
			it "requires more information from the provider" do
				allow(Stripe::Account).to receive(:retrieve).with(any_args) do
					stripe_account_pending_verification
				end
				get :stripe_connect
				expect(response).to redirect_to stripe_dashboard_url
			end
		end
		
		context "there was a problem completing the setup" do
			it "reports the problem" do
				allow_any_instance_of(StripeInfo).to receive(:configure_authorization).and_return(false)
				get :stripe_connect
				expect(response).to render_template 'error'
			end
		end
	end
end
