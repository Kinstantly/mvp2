require "spec_helper"

describe ProfileMailer, :type => :mailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	REVIEW_MODERATOR_EMAIL
	
	context "moderator notification email" do
		before(:each) do
			@review = FactoryGirl.create :review_by_parent
			@email = ReviewMailer.notify_moderator @review
		end
		
		it "should be set to be delivered to the moderator email" do
			expect(@email).to deliver_to(REVIEW_MODERATOR_EMAIL)
		end

		it "should contain profile name and reviewer username" do
			expect(@email).to have_subject(/#{@review.profile.company_otherwise_display_name} by #{@review.reviewer_username}/)
			expect(@email).to have_body_text(/#{@review.profile.company_otherwise_display_name} by #{@review.reviewer_username}/)

		end

		it "should contain review title" do
			expect(@email).to have_body_text(/#{@review.title}/)
		end
		
		it "should contain review body" do
			expect(@email).to have_body_text(/#{@review.body}/)
		end

		it "should contain review good-to-know" do
			expect(@email).to have_body_text(/#{@review.good_to_know}/)
		end

		it "should contain a link for admin view of edit profile" do
			expect(@email).to have_body_text(/#{edit_plain_profile_url(@review.profile)}#edit_review_div_#{@review.id}"/)
		end
	end
end
