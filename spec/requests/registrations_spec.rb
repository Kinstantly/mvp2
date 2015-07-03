require "spec_helper"

describe "User registration and editing", :type => :request do
	context "registering as a parent" do
		let(:parent_attributes) { FactoryGirl.attributes_for :parent }
		let(:parent_sign_up_attributes) { {
			email: parent_attributes[:email],
			password: parent_attributes[:password],
			password_confirmation: parent_attributes[:password_confirmation]
		} }
		
		it "redirects to the sign-up confirmation page" do
			post user_registration_path, user: parent_sign_up_attributes
			expect(response).to redirect_to member_awaiting_confirmation_url email_pending_confirmation: 't'
		end
		
		context "coming from the blog" do
			it "redirects to the sign-up confirmation page" do
				get new_user_registration_path(blog: 't')
				post user_registration_path, user: parent_sign_up_attributes
				expect(response).to redirect_to member_awaiting_confirmation_url email_pending_confirmation: 't'
			end
		end

		context "in-blog sign-up", in_blog: true do
			it "renders the view" do
				get in_blog_sign_up_path
				expect(response).to be_success
				expect(response).to render_template('in_blog_new')
			end
			it "redirects to in-blog confirmation page" do
				get in_blog_sign_up_path
				post user_registration_path, in_blog: true, user: parent_sign_up_attributes
				expect(response).to redirect_to in_blog_awaiting_confirmation_url email_pending_confirmation: 't'
			end
		end
	end
	
	context "logged in as a parent" do
		let(:parent) { FactoryGirl.create :parent }
		
		before (:each) do
			# sign in as a parent
			post user_session_path, user: { email: parent.email, password: parent.password }
		end
		
		it "redirects to the subscriptions edit page when requesting contact preferences editing" do
			get edit_user_registration_url(contact_preferences: 't')
			expect(response).to redirect_to edit_subscriptions_url
		end
		
		it "redirects to the home page if requesting the registration page" do
			get new_user_registration_path
			expect(response).to redirect_to root_url
		end
		
		it "redirects to the subscriptions edit page if requesting the newsletter sign-up page" do
			get new_user_registration_path(nlsub: 't')
			expect(response).to redirect_to edit_subscriptions_url
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
			expect(response).to redirect_to member_awaiting_confirmation_url email_pending_confirmation: 't'
		end
		
		context "coming from the blog" do
			it "redirects to the sign-up confirmation page" do
				get new_user_registration_path(blog: 't')
				post user_registration_path, user: provider_sign_up_attributes
				expect(response).to redirect_to member_awaiting_confirmation_url email_pending_confirmation: 't'
			end
		end
	end
	
	context "logged in as a provider" do
		let(:provider) { FactoryGirl.create :provider }
		
		before (:each) do
			# sign in as a provider
			post user_session_path, user: { email: provider.email, password: provider.password }
		end
		
		it "redirects to the subscriptions edit page when requesting contact preferences editing" do
			get edit_user_registration_url(contact_preferences: 't')
			expect(response).to redirect_to edit_subscriptions_url
		end
		
		it "redirects to my profile edit page if requesting the registration page" do
			get new_user_registration_path
			expect(response).to redirect_to edit_my_profile_url
		end
		
		it "redirects to the subscriptions edit page if requesting the newsletter sign-up page" do
			get new_user_registration_path(nlsub: 't')
			expect(response).to redirect_to edit_subscriptions_url
		end
	end
end
