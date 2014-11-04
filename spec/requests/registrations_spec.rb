require "spec_helper"

describe "User registration and editing" do
	context "logged in as a parent" do
		let(:parent) { FactoryGirl.create :parent }
		
		before (:each) do
			# sign in as a parent
			post user_session_path, user: { email: parent.email, password: parent.password }
		end
		
		it "redirects using the needed fragment identifier when requesting contact preferences editing" do
			get edit_user_registration_url(contact_preferences: 't')
			response.should redirect_to(edit_user_registration_url + '#contact_preferences')
		end
	end
end
