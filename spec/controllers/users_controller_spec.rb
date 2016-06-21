require 'spec_helper'

describe UsersController, :type => :controller do
	context "site visitor that is not logged in" do
		describe "GET edit_subscriptions" do
			it "should require login" do
				get :edit_subscriptions
				expect(response).to redirect_to new_user_session_url
			end
		end
		
		describe "PUT edit_subscriptions" do
			it "should require login" do
				put :update_subscriptions, user: {parent_newsletters: '1'}
				expect(response).to redirect_to new_user_session_url
			end
		end
	end
	
	context "as a parent" do
		let(:parent) { FactoryGirl.create :parent }
		
		before(:example) do
			sign_in parent
		end
		
		describe "GET edit_subscriptions" do
			it "should render the subscriptions management view" do
				get :edit_subscriptions
				expect(response).to render_template('edit_subscriptions')
			end
		end
		
		describe "PUT edit_subscriptions" do
			it "should return to the subscription management page after a successful update" do
				put :update_subscriptions, user: {parent_newsletters: '1'}
				expect(response).to redirect_to edit_subscriptions_url
			end
			
			it "should update the parent's subscriptions" do
				put :update_subscriptions, user: {parent_newsletters: '1', provider_newsletters: '0'}
				expect(assigns[:user].parent_newsletters).to be_truthy
				expect(assigns[:user].provider_newsletters).to be_falsey
			end
			
			it "should not update the email address" do
				expect {
					put :update_subscriptions, user: {email: 'wrong@example.org'}
				}.to_not change { parent.reload.email }
			end
			
			it "should not update the password" do
				expect {
					put :update_subscriptions, user: {password: 'noway2change', password_confirmation: 'noway2change'}
				}.to_not change { parent.reload.encrypted_password }
			end
		end
		
		context 'trying to access the user admin interface' do
			describe "GET users show" do
				it 'should not allow the parent to see their user admin record' do
					get :show, id: parent.id
					expect(response).not_to render_template('show')
				end
			end
			
			describe "GET users edit" do
				it 'should not allow the parent to edit their user admin record' do
					expect {
						get :edit, id: parent.id
					}.to raise_error ActionController::UrlGenerationError
				end
			end
			
			describe "PUT users update" do
				it 'should not allow the parent to update their user admin record' do
					expect {
						put :update, id: parent.id, user: {username: 'new_username'}
					}.to raise_error ActionController::UrlGenerationError
				end
			end
		end
	end
	
	context "as a provider" do
		let(:provider) { FactoryGirl.create :provider }
	
		before (:each) do
			sign_in provider
		end
		
		describe "GET edit_subscriptions" do
			it "should render the subscriptions management view" do
				get :edit_subscriptions
				expect(response).to render_template('edit_subscriptions')
			end
		end
		
		describe "PUT edit_subscriptions" do
			it "should return to the subscription management page after a successful update" do
				put :update_subscriptions, user: {provider_newsletters: '1'}
				expect(response).to redirect_to edit_subscriptions_url
			end
			
			it "should update the provider's subscriptions" do
				put :update_subscriptions, user: {parent_newsletters: '0', provider_newsletters: '1'}
				expect(assigns[:user].parent_newsletters).to be_falsey
				expect(assigns[:user].provider_newsletters).to be_truthy
			end
			
			it "should not update the email address" do
				expect {
					put :update_subscriptions, user: {email: 'wrong@example.org'}
				}.to_not change { provider.reload.email }
			end
			
			it "should not update the password" do
				expect {
					put :update_subscriptions, user: {password: 'noway2change', password_confirmation: 'noway2change'}
				}.to_not change { provider.reload.encrypted_password }
			end
		end
	
		describe "GET users index" do
			it "does not render the view" do
				expect(response).not_to render_template('index')
			end
		end

		describe "PUT update_profile_help" do
			before(:example) do
				provider.profile_help = true
				provider.save
			end
		
			it "successfully updates a profile_help attribute" do
				id = provider.id
				attrs = {profile_help: false}
				put :update_profile_help, id: id, user: attrs, format: :js
				expect(assigns[:update_succeeded]).to be_truthy
				expect(provider.reload.profile_help).to eq attrs[:profile_help]
			end
		
			it "should not update user attributes other than profile_help" do
				id = provider.id
				email = 'billie@example.com'
				put :update_profile_help,  id: id, user: {email: email, profile_help: false}, format: :js
				expect(provider.reload.email).not_to eq email
				expect(provider.unconfirmed_email).not_to eq email
			end

			it "cannot update profile_help attribute of another user" do
				other_user_id = FactoryGirl.create(:user).id
				put :update_profile_help, id: other_user_id, user: FactoryGirl.attributes_for(:user, profile_help: true), format: :js
				expect(assigns[:update_succeeded]).to be_falsey
			end
		end
	
		describe "GET claim_profile" do
			let(:token) { '2857251c-64e2-11e2-93ca-00264afffe0a' }
			let(:claimable_profile) {
				FactoryGirl.create(:profile, invitation_email: 'Montserrat@Caballe.com', invitation_token: token)
			}
		
			before(:example) do
				claimable_profile.reload.user = nil
				claimable_profile.save
			end
		
			context "as provider with no profile" do
				before(:example) do
					provider.reload.profile = nil
					provider.save
				end
			
				it "successfully attaches the profile with the given token to the current user" do
					get :claim_profile, token: token
					expect(provider.reload.profile).to eq claimable_profile
				end
		
				it "redirects to profile view page upon successful claim" do
					get :claim_profile, token: token
					expect(response).to redirect_to(claim_profile_tracking_parameter.merge controller: 'profiles', action: 'view_my_profile')
				end
		
				it "redirects to home page when claim fails" do
					get :claim_profile, token: 'bad-token'
					expect(response).to redirect_to root_url claim_profile_tracking_parameter
					expect(flash[:alert]).not_to be_nil
				end
			
				it "fails if profile was already claimed" do
					profile = claimable_profile
					profile.user = FactoryGirl.create(:expert_user, email: 'email@hasnotbeentaken.com')
					profile.save
					get :claim_profile, token: profile.invitation_token
					expect(response).to redirect_to root_url claim_profile_tracking_parameter
					expect(flash[:alert]).not_to be_nil
				end
			end
		
			context "as provider that already has a profile" do
				it "should ask for confirmation when claiming the profile in the invitation" do
					get :claim_profile, token: token
					expect(response).to redirect_to confirm_claim_profile_url(claim_profile_tracking_parameter.merge claim_token: token)
				end
			
				it "should succeed when forcing the claim to replace existing profile" do
					get :force_claim_profile, token: token
					expect(response).to redirect_to(claim_profile_tracking_parameter.merge controller: 'profiles', action: 'view_my_profile')
					expect(provider.reload.profile).to eq claimable_profile
				end
			end
		end
		
		context 'trying to access the user admin interface' do
			let(:client_user) { FactoryGirl.create :client_user }
			
			describe "GET users show" do
				it 'should not allow the provider to see their user admin record' do
					get :show, id: provider.id
					expect(response).not_to render_template('show')
				end
				
				it "should not allow the provider to access another user admin record" do
					get :show, id: client_user.id
					expect(response).not_to render_template('show')
				end
			end
			
			describe "GET users edit" do
				it 'should not allow the provider to edit their user admin record' do
					expect {
						get :edit, id: provider.id
					}.to raise_error ActionController::UrlGenerationError
				end
			end
			
			describe "PUT users update" do
				it 'should not allow the provider to update their user admin record' do
					expect {
						put :update, id: provider.id, user: {username: 'new_username'}
					}.to raise_error ActionController::UrlGenerationError
				end
			end
		end
	end
	
	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'bossy@example.com' }
		let(:bert) { FactoryGirl.create :provider, email: 'bert@example.com' }
		let(:ernie) { FactoryGirl.create :provider, email: 'ernie@example.com' }
		
		before(:example) do
			sign_in admin_user
		end
		
		describe "GET users index" do
			before(:example) do
				bert and ernie
				get :index
			end

			it "renders the view" do
				expect(response).to render_template('index')
			end

			it "assigns @users" do
				User.all.each do |user|
					expect(assigns[:users]).to include user
				end
			end
		end
		
		describe "GET users show" do
			before(:example) do
				get :show, id: bert.id
			end
			
			it "renders the view" do
				expect(response).to render_template('show')
			end
			
			it "assigns @user" do
				expect(assigns[:user]).to eq bert
			end
		end
	end
end
