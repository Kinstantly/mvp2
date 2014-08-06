require "spec_helper"

describe ProfileMailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "invitation email" do
		let(:recipient) { 'maria@stuarda.com' }
		let(:subject) { 'Claim your profile' }
		let(:body) { 'We are inviting you to claim your profile.' }
		let(:delivery_token) { '895d1d74-1951-11e4-83cc-00264afffe0a' }
		let(:profile) {
			FactoryGirl.create :profile,
				invitation_email: recipient,
				invitation_token: '2857251c-64e2-11e2-93ca-00264afffe0a'
		}
		
		context "with plain message body" do
			let(:email) { ProfileMailer.invite recipient, subject, body, profile, delivery_token }
		
			it "should be set to be delivered to the specified recipient" do
				email.should deliver_to(recipient)
			end

			it "should use the specified the subject" do
				email.should have_subject(subject)
			end
		
			it "should use the specified message body" do
				email.should have_body_text(body)
			end
			
			it "should contain an unsubscribe link" do
				email.should have_body_text(new_contact_blocker_from_email_delivery_url email_delivery_token: delivery_token)
			end
		end
		
		context "with claim URL in the message body" do
			let(:body_with_claim_url) { body + ' <a href="<<claim_url>>">Click here.</a>' }
			let(:email) { ProfileMailer.invite recipient, subject, body_with_claim_url, profile, delivery_token }
		
			it "should contain a link for claiming the profile" do
				email.should have_body_text(/#{claim_user_profile_url(token: profile.invitation_token)}/)
			end
		end
	end
end
