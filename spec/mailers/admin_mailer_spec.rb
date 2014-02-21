require "spec_helper"

describe AdminMailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "update_alert" do
		before(:each) do
			@profile = FactoryGirl.create :profile
			@email = AdminMailer.on_update_alert @profile
		end
		
		it "should be set to be delivered to profile admin" do
			@email.should deliver_to(PROFILE_MODERATOR_EMAIL)
		end

		it "should mention Kinstantly in the subject" do
			@email.should have_subject(/kinstantly/i)
		end
	
		it "should contain a link to edit profile view" do
			@email.should have_body_text(/#{edit_plain_profile_url(@profile)}/)
		end
	end
end
