require 'spec_helper'

describe StripeInfo, payments: true do
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
		stripe_info.configure_authorization(omniauth_values).should be_true
		stripe_info.stripe_user_id.should == stripe_user_id
		stripe_info.access_token.should == access_token
		stripe_info.publishable_key.should == publishable_key
	end
	
	it "sends a welcome email to a newly connected provider" do
		StripeConnectMailer.should_receive(:welcome_provider).and_return(double('Mail::Message').as_null_object)
		stripe_info.configure_authorization(omniauth_values)
	end
end
