require "spec_helper"

describe "User sign-in and sign-out" do
	context "sign in as a parent" do
		let(:parent) { FactoryGirl.create :parent }
		let(:parent_credentials) { { email: parent.email, password: parent.password } }
		
		it "redirects to the home page after signing in" do
			get new_user_session_path
			# sign in as a parent
			post user_session_path, user: parent_credentials
			response.should redirect_to '/'
		end
		
		context "starting at newsletter sign-up form" do
			it "redirects to the contact preferences edit page after signing in" do
				get new_user_registration_path(blog: 't')
				# sign in as a parent
				post user_session_path, user: parent_credentials
				response.should redirect_to(edit_user_registration_url + '#contact_preferences')
			end
		end
	end
	
	context "sign in as a provider" do
		let(:provider) { FactoryGirl.create :provider }
		let(:provider_credentials) { { email: provider.email, password: provider.password } }
		
		it "redirects to the provider's profile page after signing in" do
			get new_user_session_path
			# sign in as a provider
			post user_session_path, user: provider_credentials
			response.should redirect_to edit_my_profile_path
		end
	end
end
