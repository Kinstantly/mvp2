require "spec_helper"

describe AdminMailer, :type => :mailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "update_alert" do
		let(:profile) { FactoryGirl.create :profile }
		let(:email) { AdminMailer.on_update_alert profile }
		
		it "should be set to be delivered to profile admin" do
			expect(email).to deliver_to(PROFILE_MODERATOR_EMAIL)
		end

		it "should mention Kinstantly in the subject" do
			expect(email).to have_subject(/kinstantly/i)
		end
	
		it "should contain a link to edit profile view" do
			expect(email).to have_body_text(/#{edit_plain_profile_url(profile)}/)
		end
	end
	
	context "provider registration alert" do
		let(:provider) { FactoryGirl.create :provider_with_published_profile }
		let(:profile) { provider.profile }
		let(:email) { AdminMailer.provider_registration_alert provider }
		
		it "should be set to be delivered to admin" do
			expect(email).to deliver_to(ADMIN_EMAIL)
		end

		it "should show the provider's email address in the subject" do
			expect(email).to have_subject(/#{provider.email}/)
		end
	
		it "should contain a link to edit profile view" do
			expect(email).to have_body_text(edit_plain_profile_url profile)
		end
	
		it "should contain a link to view the provider's account" do
			expect(email).to have_body_text(user_url provider)
		end
	end

	context "newsletter subscribe alert" do
		let(:subscriber_email)	{'subscriber1@newsletter.com'}
		let(:subscriptions)		{[:parent_newsletters]}
		let(:email) { AdminMailer.newsletter_subscribe_alert(subscriptions, subscriber_email) }

		it "should be set to be delivered to admin" do
			expect(email).to deliver_to(ADMIN_EMAIL)
		end

		it "should show the subscriber's email in the subject" do
			expect(email).to have_subject(/#{subscriber_email}/)
		end

		it "should list newsletter editions user has subscribed to" do
			expect(email).to have_body_text(subscriptions.map{ |list| User.human_attribute_name list }.join(', '))
		end
	end

	context "newsletter unsubscribe alert" do
		let(:subscriber_email)	{'subscriber1@newsletter.com'}
		let(:subscription)		{User.human_attribute_name :parent_newsletters}
		let(:email) { AdminMailer.newsletter_unsubscribe_alert(subscription, subscriber_email) }

		it "should be set to be delivered to admin" do
			expect(email).to deliver_to(ADMIN_EMAIL)
		end

		it "should show the subscriber's email in the subject" do
			expect(email).to have_subject(/#{subscriber_email}/i)
		end

		it "should contain newsletter edition user has unsubscribed from" do
			expect(email).to have_body_text(/#{subscription}/i)
		end
	end
	
	context "parent registration alert" do
		let(:parent) { FactoryGirl.create :parent }
		let(:email) { AdminMailer.parent_registration_alert parent }
		
		it "should be set to be delivered to admin" do
			expect(email).to deliver_to(ADMIN_EMAIL)
		end

		it "should show the parent's email address in the subject" do
			expect(email).to have_subject(/#{parent.email}/)
		end
	
		it "should contain a link to view the parent's account" do
			expect(email).to have_body_text(user_url parent)
		end
	end
	
	context "provider suggestion notice" do
		let(:provider_suggestion) { FactoryGirl.create :provider_suggestion }
		let(:email) { AdminMailer.provider_suggestion_notice provider_suggestion }
		
		it "should be delivered to profile admin" do
			expect(email).to deliver_to(PROFILE_MODERATOR_EMAIL)
		end

		it "should mention 'provider suggestion' in the subject" do
			expect(email).to have_subject(/provider suggestion/i)
		end
	
		it "should contain a link to view the provider suggestion" do
			expect(email).to have_body_text(/#{provider_suggestion_url(provider_suggestion)}/)
		end
	end

	context "profile claim notice" do
		let(:profile_claim) { FactoryGirl.create :profile_claim }
		let(:email) { AdminMailer.profile_claim_notice profile_claim }
		
		it "should be delivered to profile admin" do
			expect(email).to deliver_to(PROFILE_MODERATOR_EMAIL)
		end

		it "should mention 'profile claim' in the subject" do
			expect(email).to have_subject(/profile claim/i)
		end
	
		it "should contain a link to view the claim" do
			expect(email).to have_body_text(/#{profile_claim_url(profile_claim)}/)
		end
	end
end
