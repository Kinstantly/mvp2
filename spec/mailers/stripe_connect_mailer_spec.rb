require "spec_helper"

describe StripeConnectMailer, payments: true do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "email to welcome the newly connected provider" do
		let(:provider) { FactoryGirl.create :payable_provider }
		let(:provider_email) { provider.email }
		let(:provider_profile) { provider.profile }
		
		let(:email) { StripeConnectMailer.welcome_provider provider }
		
		it "should be delivered to the provider" do
			email.should deliver_to provider_email
		end
		
		it "should identify the provider" do
			email.should have_body_text provider_profile.first_name
		end
		
		it "should have a link to the client list" do
			email.should have_body_text customer_files_url
		end
		
		it "should have a link to the Stripe dashboard" do
			email.should have_body_text stripe_dashboard_url
		end
		
		it "should have a link to the provider's payment introduction" do
			email.should have_body_text about_payments_profile_url provider_profile
		end
		
		it "should mention payments in the subject" do
			email.should have_subject /payment/
		end
	end
	
end
