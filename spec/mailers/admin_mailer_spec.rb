require "spec_helper"

describe AdminMailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "update_alert" do
		let(:profile) { FactoryGirl.create :profile }
		let(:email) { AdminMailer.on_update_alert profile }
		
		it "should be set to be delivered to profile admin" do
			email.should deliver_to(PROFILE_MODERATOR_EMAIL)
		end

		it "should mention Kinstantly in the subject" do
			email.should have_subject(/kinstantly/i)
		end
	
		it "should contain a link to edit profile view" do
			email.should have_body_text(/#{edit_plain_profile_url(profile)}/)
		end
	end
	
	context "provider registration alert" do
		let(:provider) { FactoryGirl.create :provider_with_published_profile }
		let(:profile) { provider.profile }
		let(:email) { AdminMailer.provider_registration_alert provider }
		
		it "should be set to be delivered to profile admin" do
			email.should deliver_to(PROFILE_MODERATOR_EMAIL)
		end

		it "should show the provider's email address in the subject" do
			email.should have_subject(/#{provider.email}/)
		end
	
		it "should contain a link to edit profile view" do
			email.should have_body_text(edit_plain_profile_url profile)
		end
	end
	
	context "parent registration alert" do
		let(:parent) { FactoryGirl.create :parent }
		let(:email) { AdminMailer.parent_registration_alert parent }
		
		it "should be set to be delivered to profile admin" do
			email.should deliver_to(ADMIN_EMAIL)
		end

		it "should show the parent's email address in the subject" do
			email.should have_subject(/#{parent.email}/)
		end
	
		it "should contain a link to edit the parent's account" do
			email.should have_body_text(edit_user_url parent)
		end
	end
end
