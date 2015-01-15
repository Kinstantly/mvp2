require "spec_helper"

describe CustomerMailer, payments: true do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "email confirmation for charge authorization by a parent" do
		let(:authorized_amount_usd) { '47' }
		let(:customer_file) { FactoryGirl.create :customer_file, authorized_amount_usd: authorized_amount_usd }
		let(:customer) { customer_file.customer }
		let(:user) { customer.user }
		let(:provider) { customer_file.provider }
		let(:provider_email) { provider.email }
		let(:provider_profile) { provider.profile }
		
		let(:email) { CustomerMailer.confirm_authorized_amount customer_file }
		
		it "should be delivered to the customer" do
			email.should deliver_to user.email
		end
		
		it "should identify the provider" do
			email.should have_body_text provider_profile.company_otherwise_display_name
		end
		
		it "should have a link to the provider's profile" do
			email.should have_body_text profile_url provider_profile
		end
		
		it "should have a link to the payments page" do
			email.should have_body_text customer_url customer
		end
		
		it "should have a link to the authorization page" do
			email.should have_body_text authorize_payment_url provider_profile
		end
		
		it "should show the authorized amount" do
			email.should have_body_text display_currency_amount customer_file.authorized_amount_usd
		end
		
		it "should show the card information" do
			email.should have_body_text display_payment_card_summary customer_file.stripe_card
		end
		
		it "should mention authorization in the subject" do
			email.should have_subject /auth/
		end
	end
	
end
