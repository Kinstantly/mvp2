require "spec_helper"

describe CustomerMailer, payments: true do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "charge authorization by a parent" do
		let(:authorized_amount_usd) { '47' }
		let(:customer_file) { FactoryGirl.create :customer_file, authorized_amount_usd: authorized_amount_usd }
		let(:customer) { customer_file.customer }
		let(:user) { customer.user }
		let(:provider) { customer_file.provider }
		let(:provider_email) { provider.email }
		let(:provider_profile) { provider.profile }
		
		context "email confirmation to the parent" do
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
		
			# it "should have a link to the payments page" do
			# 	email.should have_body_text customer_url customer
			# end
		
			it "should have a link to the authorization page" do
				email.should have_body_text authorize_payment_url provider_profile
			end
		
			it "should show the authorized amount" do
				email.should have_body_text display_currency_amount customer_file.authorized_amount_usd
			end
		
			# it "should show the card information" do
			# 	email.should have_body_text display_payment_card_in_email customer_file.stripe_card
			# end
		
			it "should mention authorization in the subject" do
				email.should have_subject /auth/
			end
		end
		
		context "notify the provider" do
			let(:email) { CustomerMailer.notify_provider_of_payment_authorization customer_file }
		
			it "should be delivered to the provider" do
				email.should deliver_to provider_email
			end
		
			it "should identify the client" do
				email.should have_body_text user.username
			end
		
			it "should have a link to the customer details page" do
				email.should have_body_text customer_file_url customer_file
			end
		
			# it "should show the authorized amount" do
			# 	email.should have_body_text display_currency_amount customer_file.authorized_amount_usd
			# end
		
			it "should mention authorization in the subject" do
				email.should have_subject /auth/
			end
		end
	end
	
	context "revoked authorization by a parent" do
		let(:customer_file) { FactoryGirl.create :second_customer_file, authorized: false }
		let(:customer) { customer_file.customer }
		let(:user) { customer.user }
		let(:provider) { customer_file.provider }
		let(:provider_email) { provider.email }
		let(:provider_profile) { provider.profile }
		
		context "email confirmation to the parent" do
			let(:email) { CustomerMailer.confirm_revoked_authorization customer_file }
		
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
		
			it "should mention revocation in the subject" do
				email.should have_subject /revoked/
			end
		
			it "should mention revocation in the message body" do
				email.should have_body_text "no longer has permission to charge your card"
			end
		end
		
		context "notify the provider" do
			let(:email) { CustomerMailer.notify_provider_of_revoked_authorization customer_file }
		
			it "should be delivered to the provider" do
				email.should deliver_to provider_email
			end
		
			it "should identify the client" do
				email.should have_body_text user.username
			end
		
			it "should have a link to the customer details page" do
				email.should have_body_text customer_file_url customer_file
			end
		
			it "should mention revocation in the subject" do
				email.should have_subject /revoked/
			end
		
			it "should mention revocation in the message body" do
				email.should have_body_text "has revoked payment authorization"
			end
		end
	end
end
