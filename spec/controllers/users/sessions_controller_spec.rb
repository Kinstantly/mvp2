require 'spec_helper'

describe Users::SessionsController, :type => :controller do
	let(:parent) { FactoryGirl.create :parent }
	let(:provider) { FactoryGirl.create :provider }
	let(:admin_user) { FactoryGirl.create :admin_user }
		
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	it "should be a child of Devise::SessionsController" do
		expect(controller.class.superclass).to eq Devise::SessionsController
	end

	context "as a parent" do
		describe "POST sessions" do
			it "redirects to home page after log in" do
				post :create, user: { email: parent.email, password: parent.password }
				expect(response).to redirect_to '/'
				expect(flash[:notice]).to have_content 'successful'
			end

			it "stays on log-in page with bad password" do
				post :create, user: { email: parent.email, password: "#{parent.password}x" }
				expect(response).to render_template :new
				expect(flash[:alert]).to have_content /invalid.*password/i
			end
		end
		
		describe "DELETE sessions" do
			it "redirects to home page for log out" do
				sign_in parent
				delete :destroy
				expect(response).to redirect_to '/'
				expect(flash[:notice]).to have_content 'successful'
			end
		end
	end

	context "as a provider" do
		describe "POST sessions" do
			it "redirects to provider's profile edit page after log in" do
				post :create, user: { email: provider.email, password: provider.password }
				expect(response).to redirect_to '/edit_my_profile'
				expect(flash[:notice]).to have_content 'successful'
			end

			it "stays on log-in page with bad password" do
				post :create, user: { email: provider.email, password: "#{provider.password}x" }
				expect(response).to render_template :new
				expect(flash[:alert]).to have_content /invalid.*password/i
			end
		end
		
		describe "DELETE sessions" do
			it "redirects to home page for log out" do
				sign_in provider
				delete :destroy
				expect(response).to redirect_to '/'
				expect(flash[:notice]).to have_content 'successful'
			end
		end
	end

	context "as admin user" do
		describe "POST sessions" do
			it "redirects to admin user's profile edit page after log in" do
				post :create, user: { email: admin_user.email, password: admin_user.password }
				expect(response).to redirect_to '/'
				expect(flash[:notice]).to have_content 'successful'
			end

			it "stays on log-in page with bad password" do
				post :create, user: { email: admin_user.email, password: "#{admin_user.password}x" }
				expect(response).to render_template :new
				expect(flash[:alert]).to have_content /invalid.*password/i
			end
		end
		
		describe "DELETE sessions" do
			it "redirects to home page for log out" do
				sign_in admin_user
				delete :destroy
				expect(response).to redirect_to '/'
				expect(flash[:notice]).to have_content 'successful'
			end
		end
	end
end
