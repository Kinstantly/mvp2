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
				flash[:notice].should have_content 'confirm'
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
					flash[:notice].should have_content 'confirm'
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
			it "redirects back to the user account page after confirmation" do
				post :create, user: {email: mimi.email, admin_confirmation_sent_by_id: bossy.id}
				response.should redirect_to user_path mimi
			end

			context "when running as a private site", private_site: true do
				it "redirects back to the user account page after confirmation" do
					post :create, user: {email: mimi.email, admin_confirmation_sent_by_id: bossy.id}
					response.should redirect_to user_path mimi
				end
			end
		end
	end
end
