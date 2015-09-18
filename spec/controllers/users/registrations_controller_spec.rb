require 'spec_helper'

describe Users::RegistrationsController, :type => :controller do
	let(:email) { 'mimi@la.boheme.it' }
	let(:new_password) { 'Pucc1n1!' }
	let(:username) { 'Giacomo' }
	
	before(:example) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end
	
	context "as a non-provider member" do
		describe "POST create" do
			context "new user signs up" do
				it "subscribes to the parent mailing lists" do
					post :create, user: {
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username,
						parent_newsletters: true,
					}

					user = assigns[:user].reload
					expect(user.parent_newsletters).to be_truthy
					expect(user.provider_newsletters).to be_falsey
				end

				it "does not subscribe to the mailing lists" do
					post :create, user: {
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username,
						parent_newsletters: false,
					}

					user = assigns[:user].reload
					expect(user.parent_newsletters).to be_falsey
					expect(user.provider_newsletters).to be_falsey
				end
				
				it 'can not access forbidden attributes' do
					post :create, user: {
						email: email,
						password: new_password,
						password_confirmation: new_password,
						failed_attempts: 5
					}
					
					user = assigns[:user].reload
					expect(user.email).to eq email
					expect(user.failed_attempts).to eq 0 # should be forbidden and thus unchanged
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
				expect(response).to redirect_to edit_user_registration_url
				expect(flash[:notice]).to have_content 'confirmation'
			end
		
			it "fails to update email address with double quote" do
				put :update, user: {email: email+'"', current_password: mimi.password}
				expect(response).to render_template('edit')
			end
		
			it "fails to update email address with single quote" do
				put :update, user: {email: email+"'", current_password: mimi.password}
				expect(response).to render_template('edit')
			end
			
			it 'can not access forbidden attributes' do
				new_username = mimi.username + '_new'
				put :update, user: {username: new_username, failed_attempts: 5, current_password: mimi.password}
				user = assigns[:user].reload
				expect(user.username).to eq new_username
				expect(user.failed_attempts).to eq 0 # should be forbidden and thus unchanged
			end
			
			context "with mailing lists" do
				it "can subscribe to mailing lists" do
					put :update, user: {
						parent_newsletters: true,
						current_password: mimi.password
					}
				
					user = assigns[:user].reload
					expect(user.parent_newsletters).to be_truthy
				end
			
				it "cannot subscribe to mailing lists if previously blocked" do
					FactoryGirl.create :contact_blocker, email: mimi.email
					put :update, user: {
						parent_newsletters: true,
						current_password: mimi.password
					}
				
					user = assigns[:user].reload
					expect(user.parent_newsletters).to be_falsey
				end
			end
		end
	end
	
	context "as a provider" do
		describe "POST create" do
			context "new provider signs up" do
				it "subscribes to the provider mailing lists" do
					post :create, user: {
						is_provider: '1',
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username,
						parent_newsletters: true,
						provider_newsletters: true
					}

					user = assigns[:user].reload
					expect(user.parent_newsletters).to be_truthy
					expect(user.provider_newsletters).to be_truthy
				end

				it "does not subscribe to the mailing lists" do
					post :create, user: {
						is_provider: '1',
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username,
						parent_newsletters: false,
						provider_newsletters: false
					}

					user = assigns[:user].reload
					expect(user.parent_newsletters).to be_falsey
					expect(user.provider_newsletters).to be_falsey
				end
				
				context "while claiming a profile" do
					it "subscribes the provider to the provider mailing lists" do
						profile = FactoryGirl.create :claimable_profile
						session[:claiming_profile] = profile.invitation_token
					
						post :create, user: {
							is_provider: '1',
							email: email,
							password: new_password,
							password_confirmation: new_password,
							username: username,
							parent_newsletters: true,
							provider_newsletters: true
						}

						user = assigns[:user].reload
						expect(user.parent_newsletters).to be_truthy
						expect(user.provider_newsletters).to be_truthy
					end
				end
			end

			context "after registration" do
				before(:example) do
					post :create, user: {
						is_provider: '1',
						email: email,
						password: new_password,
						password_confirmation: new_password,
						username: username,
						parent_newsletters: true
					}
				end
			
				let(:provider) { User.find_by_email email }
			
				it "displays confirmation notice with tracking parameters" do
					expect(response).to redirect_to '/member/awaiting_confirmation?email_pending_confirmation=t&parent_newsletters=t&provider=t'
				end
				
				it "has a profile" do
					expect(provider.profile).not_to be_nil
				end
			
				it "has a published profile" do
					expect(provider.profile.is_published).to be_truthy
				end
			end
		end
	end
end
