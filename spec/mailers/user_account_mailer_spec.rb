require "spec_helper"

describe UserAccountMailer, :type => :mailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "confirmation email to a parent" do
		let(:user) { FactoryGirl.create :parent, require_confirmation: true }
		let(:email) { UserAccountMailer.on_create_confirmation_instructions user, 'token' }
		
		it "should deliver to the user" do
			expect(email).to deliver_to(user.email)
		end
		
		it "should have the confirmation email subject" do
			expect(email).to have_subject(I18n.t 'devise.mailer.on_create_confirmation_instructions.subject')
		end
		
		it "should contain a confirmation link" do
			expect(email).to have_body_text(user_confirmation_url)
		end
	end
	
	context "confirmation email to a provider" do
		let(:user) { FactoryGirl.create :provider, require_confirmation: true }
		let(:email) { UserAccountMailer.on_create_provider_confirmation_instructions user, 'token' }
		
		it "should deliver to the user" do
			expect(email).to deliver_to(user.email)
		end
		
		it "should have the confirmation email subject" do
			expect(email).to have_subject(I18n.t 'devise.mailer.on_create_provider_confirmation_instructions.subject')
		end
		
		it "should contain a confirmation link" do
			expect(email).to have_body_text(user_confirmation_url)
		end
	end
	
	context "welcome email to a provider" do
		let(:user) { FactoryGirl.create :provider_with_published_profile }
		let(:email) { UserAccountMailer.on_create_welcome user }
		
		it "should deliver to the user" do
			expect(email).to deliver_to(user.email)
		end
		
		it "should have the welcome email subject" do
			expect(email).to have_subject(I18n.t 'devise.mailer.on_create_welcome.subject')
		end
		
		it "should contain a link to the provider's profile edit page" do
			expect(email).to have_body_text(edit_my_profile_url)
		end
	end
end
