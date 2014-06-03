require "spec_helper"

describe "Not found or accessible" do
	context "not logged in" do
		it "redirects to sign-in page when access is denied" do
			get profile_path FactoryGirl.create(:unpublished_profile)
			response.should redirect_to new_user_session_url
		end

		it "redirects to sign-in page when record not found" do
			get '/profiles/1000'
			response.should redirect_to new_user_session_url
		end

		it "redirects to sign-in page when requested path is undefined" do
			get '/supercalifragilistic'
			response.should redirect_to new_user_session_url
		end
	end

	context "logged in as a parent" do
		let(:parent) { FactoryGirl.create :parent }
		
		before (:each) do
			# sign in as a parent
			post user_session_path, user: { email: parent.email, password: parent.password }
		end
		
		it "redirects to home page when access is denied" do
			get profile_path FactoryGirl.create(:unpublished_profile)
			response.should redirect_to root_url
		end

		it "redirects to home page when record not found" do
			get '/profiles/1000'
			response.should redirect_to root_url
		end

		it "redirects to home page when requested path is undefined" do
			get '/supercalifragilistic'
			response.should redirect_to root_url
		end
	end

	context "not logged in when running as a private site", private_site: true do
		it "redirects to alpha sign-up page when access is denied" do
			get profile_path FactoryGirl.create(:unpublished_profile)
			response.should redirect_to alpha_sign_up_url
		end

		it "redirects to alpha sign-up page when record not found" do
			get '/profiles/1000'
			response.should redirect_to alpha_sign_up_url
		end

		it "redirects to alpha sign-up page when requested path is undefined" do
			get '/supercalifragilistic'
			response.should redirect_to alpha_sign_up_url
		end
	end

	context "logged in as a parent when running as a private site", private_site: true do
		let(:parent) { FactoryGirl.create :parent }
		
		before (:each) do
			# sign in as a parent
			post user_session_path, user: { email: parent.email, password: parent.password }
		end
		
		it "redirects to home page when access is denied" do
			get profile_path FactoryGirl.create(:unpublished_profile)
			response.should redirect_to root_url
		end

		it "redirects to home page when record not found" do
			get '/profiles/1000'
			response.should redirect_to root_url
		end

		it "redirects to home page when requested path is undefined" do
			get '/supercalifragilistic'
			response.should redirect_to root_url
		end
	end
end
