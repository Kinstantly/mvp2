require 'spec_helper'

describe Users::ConfirmationsController, :type => :controller do
	let(:mimi) {
		FactoryGirl.create :client_user,
		require_confirmation: true,
		admin_confirmation_sent_at: nil
	}
	let(:mimi_subscribed) {
		FactoryGirl.create :client_user, 
			require_confirmation: true,
			parent_newsletters_stage1: true,
			parent_newsletters_stage2: true
	}
	
	before(:example) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	it "should be a child of Devise::ConfirmationsController" do
		expect(controller.class.superclass).to eq Devise::ConfirmationsController
	end

	context "as a client pending email confirmation" do
		describe "GET show" do
			it "redirects to the home page with tracking parameter" do
				get :show, confirmation_token: mimi.confirmation_token
				expect(response).to redirect_to '/?email_confirmed=t'
				expect(flash[:notice]).to have_content 'confirmed'
			end
			
			it "tracking parameters indicate subscriptions" do
				get :show, confirmation_token: mimi_subscribed.confirmation_token
				expect(response).to redirect_to '/?email_confirmed=t&parent_newsletters_stage1=t&parent_newsletters_stage2=t'
				expect(flash[:notice]).to have_content 'confirmed'
			end
		end
	end

	context "as a non-admin user requesting confirmation instructions" do
		describe "POST confirmation" do
			it "redirects to sign in page after request" do
				post :create, user: {email: mimi.email}
				expect(response).to redirect_to '/users/sign_in'
				expect(flash[:notice]).to have_content 'confirm'
			end

			context "when running as a private site", private_site: true do
				it "re-renders the confirmation request page with no success notice BEFORE admin approval" do
					post :create, user: {email: mimi.email}
					expect(response).to render_template 'new'
					expect(flash[:notice]).to be_nil
				end

				it "redirects to sign in page AFTER admin approval" do
					mimi.admin_confirmation_sent_at = Time.now.utc
					mimi.save
					post :create, user: {email: mimi.email}
					expect(response).to redirect_to '/users/sign_in'
					expect(flash[:notice]).to have_content 'confirm'
				end
			end
		end
	end
	
	context "as admin user" do
		let(:bossy) { FactoryGirl.create :admin_user, email: 'bossy@example.com' }
		
		before(:example) do
			sign_in bossy
		end
		
		describe "POST confirmation" do
			it "redirects back to the user account page after confirmation" do
				post :create, user: {email: mimi.email, admin_confirmation_sent_by_id: bossy.id}
				expect(response).to redirect_to user_path mimi
			end

			context "when running as a private site", private_site: true do
				it "redirects back to the user account page after confirmation" do
					post :create, user: {email: mimi.email, admin_confirmation_sent_by_id: bossy.id}
					expect(response).to redirect_to user_path mimi
				end
			end
		end
	end
end
