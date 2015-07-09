require "spec_helper"

describe "User sign-in and sign-out", :type => :request do
	context "sign in as a parent" do
		let(:parent) { FactoryGirl.create :parent }
		let(:parent_credentials) { { email: parent.email, password: parent.password } }
		
		it "redirects to the home page after signing in" do
			get new_user_session_path
			# sign in as a parent
			post user_session_path, user: parent_credentials
			expect(response).to redirect_to '/'
		end
		
		context "starting at newsletter sign-up form" do
			it "redirects to the subscriptions edit page after signing in" do
				get new_user_registration_path(blog: 't', nlsub: 't')
				# sign in as a parent
				post user_session_path, user: parent_credentials
				expect(response).to redirect_to edit_subscriptions_url
			end
		end
	
		context "via JSON" do
			let(:sign_in_path) { user_session_path(auth_token: Rails.configuration.sign_in_auth_token) }
			let(:sign_in_path_without_auth_token) { user_session_path }

			it "responds with status 201 with a proper authentication token and correct credentials" do
				post sign_in_path, user: parent_credentials, format: :json
				expect(response.status).to eq 201
			end

			it "responds with status 401 without a proper authentication token" do
				post sign_in_path_without_auth_token, user: parent_credentials, format: :json
				expect(response.status).to eq 401
			end

			it "responds with status 401 without the correct password" do
				post sign_in_path, user: parent_credentials.merge(password: '*'), format: :json
				expect(response.status).to eq 401
			end

			it "responds with status 401 without the correct email address" do
				post sign_in_path, user: parent_credentials.merge(email: 'bad@example.com'), format: :json
				expect(response.status).to eq 401
			end

			it "responds with a noncommittal error message without the correct password" do
				post sign_in_path, user: parent_credentials.merge(password: '*'), format: :json
				expect(response.body).to include '"error":"Invalid email or password."'
			end

			it "responds with a noncommittal error message without the correct email address" do
				post sign_in_path, user: parent_credentials.merge(email: 'bad@example.com'), format: :json
				expect(response.body).to include '"error":"Invalid email or password."'
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
			expect(response).to redirect_to edit_my_profile_path
		end
	end
end
