require "spec_helper"

describe "User registration and editing" do
	context "registering as a parent" do
		let(:parent_attributes) { FactoryGirl.attributes_for :parent }
		let(:parent_sign_up_attributes) { {
			email: parent_attributes[:email],
			password: parent_attributes[:password],
			password_confirmation: parent_attributes[:password_confirmation]
		} }
		
		it "redirects to the sign-up confirmation page" do
			post user_registration_path, user: parent_sign_up_attributes
			response.should redirect_to member_awaiting_confirmation_url
		end
		
		context "coming from the blog" do
			it "redirects to the sign-up confirmation page" do
				get new_user_registration_path(blog: 't')
				post user_registration_path, user: parent_sign_up_attributes
				response.should redirect_to member_awaiting_confirmation_url
			end
		end
	end
	
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
	
	context "registering as a provider" do
		let(:provider_attributes) { FactoryGirl.attributes_for :provider }
		let(:provider_sign_up_attributes) { {
			email: provider_attributes[:email],
			password: provider_attributes[:password],
			password_confirmation: provider_attributes[:password_confirmation]
		} }
		
		it "redirects to the sign-up confirmation page" do
			post user_registration_path, user: provider_sign_up_attributes
			response.should redirect_to member_awaiting_confirmation_url
		end
		
		context "coming from the blog" do
			it "redirects to the sign-up confirmation page" do
				get new_user_registration_path(blog: 't')
				post user_registration_path, user: provider_sign_up_attributes
				response.should redirect_to member_awaiting_confirmation_url
			end
		end
	end
end
