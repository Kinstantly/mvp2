require "spec_helper"

describe UserAccountMailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "welcome email" do
		before(:each) do
			@user = FactoryGirl.create :expert_user, require_confirmation: true
			@email = UserAccountMailer.on_create_confirmation_instructions @user
		end
		
		it "should deliver to the user" do
			@email.should deliver_to(@user.email)
		end
		
		it "should have the welcome email subject" do
			@email.should have_subject(I18n.t 'devise.mailer.on_create_confirmation_instructions.subject')
		end
		
		it "should contain a confirmation link" do
			@email.should have_body_text(user_confirmation_url)
		end
	end
end
