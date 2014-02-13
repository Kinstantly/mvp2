require "spec_helper"

describe UserAccountMailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "welcome email to a parent" do
		let(:user) { FactoryGirl.create :parent, require_confirmation: true }
		let(:email) { UserAccountMailer.on_create_confirmation_instructions user }
		
		it "should deliver to the user" do
			email.should deliver_to(user.email)
		end
		
		it "should have the welcome email subject" do
			email.should have_subject(I18n.t 'devise.mailer.on_create_confirmation_instructions.subject')
		end
		
		it "should contain a confirmation link" do
			email.should have_body_text(user_confirmation_url)
		end
	end
	
	context "welcome email to a parent" do
		let(:user) { FactoryGirl.create :provider, require_confirmation: true }
		let(:email) { UserAccountMailer.on_create_provider_confirmation_instructions user }
		
		it "should deliver to the user" do
			email.should deliver_to(user.email)
		end
		
		it "should have the welcome email subject" do
			email.should have_subject(I18n.t 'devise.mailer.on_create_provider_confirmation_instructions.subject')
		end
		
		it "should contain a confirmation link" do
			email.should have_body_text(user_confirmation_url)
		end
	end
end
