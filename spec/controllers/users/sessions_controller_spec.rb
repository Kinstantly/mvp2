require 'spec_helper'

describe Users::SessionsController do
	let(:parent) { FactoryGirl.create :parent }
	let(:provider) { FactoryGirl.create :provider }
	let(:admin_user) { FactoryGirl.create :admin_user }
		
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	it "should be a child of Devise::SessionsController" do
		controller.class.superclass.should eq Devise::SessionsController
	end

	context "as a parent" do
		describe "POST sessions" do
			it "redirects to home page after log in" do
				post :create, user: { email: parent.email, password: parent.password }
				response.should redirect_to '/'
				flash[:notice].should have_content 'successful'
			end

			it "stays on log-in page with bad password" do
				post :create, user: { email: parent.email, password: "#{parent.password}x" }
				response.should render_template :new
				flash[:alert].should have_content /invalid.*password/i
			end
		end
		
		describe "DELETE sessions" do
			it "redirects to home page for log out" do
				sign_in parent
				delete :destroy
				response.should redirect_to '/'
				flash[:notice].should have_content 'successful'
			end
		end
	end

	context "as a provider" do
		describe "POST sessions" do
			it "redirects to provider's profile edit page after log in" do
				post :create, user: { email: provider.email, password: provider.password }
				response.should redirect_to '/edit_my_profile'
				flash[:notice].should have_content 'successful'
			end

			it "stays on log-in page with bad password" do
				post :create, user: { email: provider.email, password: "#{provider.password}x" }
				response.should render_template :new
				flash[:alert].should have_content /invalid.*password/i
			end
		end
		
		describe "DELETE sessions" do
			it "redirects to home page for log out" do
				sign_in provider
				delete :destroy
				response.should redirect_to '/'
				flash[:notice].should have_content 'successful'
			end
		end
	end

	context "as admin user" do
		describe "POST sessions" do
			it "redirects to admin user's profile edit page after log in" do
				post :create, user: { email: admin_user.email, password: admin_user.password }
				response.should redirect_to '/'
				flash[:notice].should have_content 'successful'
			end

			it "stays on log-in page with bad password" do
				post :create, user: { email: admin_user.email, password: "#{admin_user.password}x" }
				response.should render_template :new
				flash[:alert].should have_content /invalid.*password/i
			end
		end
		
		describe "DELETE sessions" do
			it "redirects to home page for log out" do
				sign_in admin_user
				delete :destroy
				response.should redirect_to '/'
				flash[:notice].should have_content 'successful'
			end
		end
	end
end
