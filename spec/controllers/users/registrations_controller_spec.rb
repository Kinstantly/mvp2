require 'spec_helper'

describe Users::RegistrationsController do
	let(:email) { 'mimi@la.boheme.it' }
	let(:new_password) { 'Pucc1n1!' }
	let(:username) { 'Giacomo' }
	
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end
	
	context "as a non-provider member" do
		describe "POST create" do
			context "new user signs up" do
				it "marketing_emails_and_newsletters is true" do
					post :create, user: {
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username
					}, marketing_emails_and_newsletters: true

					user = assigns[:user].reload
					user.parent_marketing_emails.should be_true
					user.parent_newsletters.should be_true
				end

				it "marketing_emails_and_newsletters is false" do
					post :create, user: {
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username
					}, marketing_emails_and_newsletters: false

					user = assigns[:user].reload
					user.parent_marketing_emails.should be_false
					user.parent_newsletters.should be_false
				end
			end
		end
	
		describe "PUT update" do
			let(:mimi) { FactoryGirl.create(:client_user) }
		
			before (:each) do
				sign_in mimi
			end

			it "updates email address for confirmation" do
				put :update, user: {email: email, current_password: mimi.password}
				response.should redirect_to '/'
				flash[:notice].should_not be_nil
			end
		
			it "fails to update email address with double quote" do
				put :update, user: {email: email+'"', current_password: mimi.password}
				response.should render_template('edit')
			end
		
			it "fails to update email address with single quote" do
				put :update, user: {email: email+"'", current_password: mimi.password}
				response.should render_template('edit')
			end
			
			it "can subscribe to mailing lists" do
				put :update, user: {
					parent_marketing_emails: true,
					parent_newsletters: true,
					current_password: mimi.password
				}
				
				user = assigns[:user].reload
				user.parent_marketing_emails.should be_true
				user.parent_newsletters.should be_true
			end
			
			it "cannot subscribe to mailing lists if previously blocked" do
				FactoryGirl.create :contact_blocker, email: mimi.email
				put :update, user: {
					parent_marketing_emails: true,
					parent_newsletters: true,
					current_password: mimi.password
				}
				
				user = assigns[:user].reload
				user.parent_marketing_emails.should be_false
				user.parent_newsletters.should be_false
			end
		end
	end
	
	context "as a provider" do
		describe "POST create" do
			context "new provider signs up" do			
				it "marketing_emails_and_newsletters is true" do
					post :create, user: {
						is_provider: '1',
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username
					}, marketing_emails_and_newsletters: true

					user = assigns[:user].reload
					user.provider_marketing_emails.should be_true
					user.provider_newsletters.should be_true
				end

				it "marketing_emails_and_newsletters is false" do
					post :create, user: {
						is_provider: '1',
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username
					}, marketing_emails_and_newsletters: false

					user = assigns[:user].reload
					user.provider_marketing_emails.should be_false
					user.provider_newsletters.should be_false
				end
			end

			context "after registration" do
				before(:each) do
					post :create, user: {
						is_provider: '1',
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username
					}
				end
			
				let(:provider) { User.find_by_email email }
			
				it "displays confirmation notice" do
					response.should redirect_to '/member/awaiting_confirmation'
				end
				
				it "has a profile" do
					provider.profile.should_not be_nil
				end
			
				it "has a published profile" do
					provider.profile.is_published.should be_true
				end
			end
		end
	end
end
