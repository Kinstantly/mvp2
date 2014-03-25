require 'spec_helper'

describe Users::ConfirmationsController do
	let(:mimi) { FactoryGirl.create :client_user, require_confirmation: true, admin_confirmation_sent_at: nil }
		
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	it "should be a child of Devise::ConfirmationsController" do
		controller.class.superclass.should eq Devise::ConfirmationsController
	end

	context "as a non-admin user requesting confirmation instructions" do
		describe "POST confirmation" do
			it "redirects to sign in page after confirmation" do
				post :create, user: {email: mimi.email}
				response.should redirect_to '/users/sign_in'
				flash[:notice].should_not be_nil
			end

			context "when running as a private site", private_site: true do
				it "re-renders the confirmation request page with no success notice BEFORE admin approval" do
					post :create, user: {email: mimi.email}
					response.should render_template 'new'
					flash[:notice].should be_nil
				end

				it "redirects to sign in page AFTER admin approval" do
					mimi.admin_confirmation_sent_at = Time.now.utc
					mimi.save
					post :create, user: {email: mimi.email}
					response.should redirect_to '/users/sign_in'
					flash[:notice].should_not be_nil
				end
			end
		end
	end
	
	context "as admin user" do
		let(:bossy) { FactoryGirl.create :admin_user, email: 'bossy@example.com' }
		
		before(:each) do
			sign_in bossy
		end
		
		describe "POST confirmation" do
			it "redirects to user admin interface after confirmation" do
				post :create, user: {email: mimi.email}
				response.should redirect_to edit_user_path mimi
			end
		end
	end
end
