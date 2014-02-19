require "spec_helper"

describe ProfileMailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "invitation email" do
		before(:each) do
			@profile = FactoryGirl.create :profile,
				invitation_email: 'maria@stuarda.com',
				invitation_token: '2857251c-64e2-11e2-93ca-00264afffe0a'
			@email = ProfileMailer.invite @profile
		end
		
		it "should be set to be delivered to the invitation email" do
			@email.should deliver_to(@profile.invitation_email)
		end

		it "should mention Kinstantly in the subject" do
			@email.should have_subject(/kinstantly/i)
		end
		
		it "should mention Kinstantly in the message body" do
			@email.should have_body_text(/kinstantly/i)
		end

		it "should contain a link for claiming the profile" do
			@email.should have_body_text(/#{claim_user_profile_url(token: @profile.invitation_token)}/)
		end
	end

	context "update_alert" do
		before(:each) do
			@profile = FactoryGirl.create :profile
			@email = ProfileMailer.on_update_alert @profile
		end
		
		it "should be set to be delivered to admin" do
			@email.should deliver_to("Jim Scott <jscott@kinstantly.com>")
		end

		it "should mention Kinstantly in the subject" do
			@email.should have_subject(/kinstantly/i)
		end
	
		it "should contain a link to edit profile view" do
			@email.should have_body_text(/#{edit_plain_profile_url(@profile)}/)
		end
	end
end
