require 'spec_helper'

describe Users::ConfirmationsController do
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	it "should be a child of Devise::ConfirmationsController" do
		controller.class.superclass.should eq Devise::ConfirmationsController
	end

	context "as a non-admin user requesting confirmation instructions" do
		describe "POST confirmation" do
			it "redirects to sign in page after confirmation" do
				@mimi = FactoryGirl.create(:client_user)
				@mimi.confirmed_at = nil
				@mimi.save

				post :create, user: {email: @mimi.email}
				response.should redirect_to '/users/sign_in'
				flash[:notice].should_not be_nil
			end
		end
	end
	
	context "as admin user" do
		describe "POST confirmation" do
			it "redirects to user admin interface after confirmation" do
				@mimi = FactoryGirl.create(:client_user)
				@mimi.confirmed_at = nil
				@mimi.save
				@bossy = FactoryGirl.create(:admin_user, email: 'bossy@example.com')
				sign_in @bossy
				
				post :create, user: {email: @mimi.email}
				response.should redirect_to edit_user_path @mimi
			end
		end
	end
end
