require 'spec_helper'

describe UsersController do
	context "site visitor that is not logged in" do
		describe "GET edit_subscriptions" do
			it "should require login" do
				get :edit_subscriptions
				response.should redirect_to new_user_session_url
			end
		end
		
		describe "PUT edit_subscriptions" do
			it "should require login" do
				put :update_subscriptions, user: {parent_newsletters_stage1: '1'}
				response.should redirect_to new_user_session_url
			end
		end
	end
	
	context "as a parent" do
		let(:parent) { FactoryGirl.create :parent }
		
		before(:each) do
			sign_in parent
		end
		
		describe "GET edit_subscriptions" do
			it "should render the subscriptions management view" do
				get :edit_subscriptions
				response.should render_template('edit_subscriptions')
			end
		end
		
		describe "PUT edit_subscriptions" do
			it "should return to the subscription management page after a successful update" do
				put :update_subscriptions, user: {parent_newsletters_stage1: '1'}
				response.should redirect_to edit_subscriptions_url
			end
			
			it "should update the parent's subscriptions" do
				put :update_subscriptions, user: {parent_newsletters_stage1: '1', provider_newsletters: '0'}
				assigns[:user].parent_newsletters_stage1.should be_true
				assigns[:user].provider_newsletters.should be_false
			end
			
			it "should not update the email address" do
				expect {
					put :update_subscriptions, user: {email: 'wrong@example.org'}
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end
			
			it "should not update the password" do
				expect {
					put :update_subscriptions, user: {password: 'noway2change', password_confirmation: 'noway2change'}
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
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
				response.should render_template('edit_subscriptions')
			end
		end
		
		describe "PUT edit_subscriptions" do
			it "should return to the subscription management page after a successful update" do
				put :update_subscriptions, user: {provider_newsletters: '1'}
				response.should redirect_to edit_subscriptions_url
			end
			
			it "should update the provider's subscriptions" do
				put :update_subscriptions, user: {parent_newsletters_stage1: '0', provider_newsletters: '1'}
				assigns[:user].parent_newsletters_stage1.should be_false
				assigns[:user].provider_newsletters.should be_true
			end
			
			it "should not update the email address" do
				expect {
					put :update_subscriptions, user: {email: 'wrong@example.org'}
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end
			
			it "should not update the password" do
				expect {
					put :update_subscriptions, user: {password: 'noway2change', password_confirmation: 'noway2change'}
				}.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end
		end
	
		describe "GET view_profile" do
			it "should not show the profile via the users controller" do
				get :view_profile
				response.should_not render_template('view_profile')
			end
		end
	
		describe "GET users index" do
			it "does not render the view" do
				response.should_not render_template('index')
			end
		end
	
		describe "GET edit_profile" do
			it "should not render the profile edit view via the users controller" do
				get :edit_profile
				response.should_not render_template('edit_profile')
			end
		end
	
		describe "POST update_profile" do
			it "should not update the profile via the users controller" do
				post :update_profile, user: FactoryGirl.attributes_for(:user)
				response.should_not redirect_to(controller: 'users', action: 'view_profile')
				flash[:alert].should_not be_nil
			end
		
			it "should not update a profile attribute via the users controller" do
				new_first_name = 'Billie Joe'
				post :update_profile, user: FactoryGirl.attributes_for(:user, profile: {first_name: new_first_name})
				assigns[:profile].first_name.should_not == new_first_name
			end
		end

		describe "PUT update_profile_help" do
			before(:each) do
				provider.profile_help = true
				provider.save
			end
		
			it "successfully updates a profile_help attribute" do
				id = provider.id
				attrs = {profile_help: false}
				put :update_profile_help, id: id, user: attrs, format: :js
				assigns[:update_succeeded].should be_true
				provider.reload.profile_help.should == attrs[:profile_help]
			end
		
			it "should not update user attributes other than profile_help" do
				id = provider.id
				email = 'billie@example.com'
				put :update_profile_help,  id: id, user: {email: email}, format: :js
				provider.reload.email.should_not == email
				provider.unconfirmed_email.should_not == email
			end

			it "cannot update profile_help attribute of another user" do
				other_user_id = FactoryGirl.create(:user).id
				put :update_profile_help, id: other_user_id, user: FactoryGirl.attributes_for(:user, profile_help: true), format: :js
				assigns[:update_succeeded].should be_false
			end
		end
	
		describe "GET claim_profile" do
			let(:token) { '2857251c-64e2-11e2-93ca-00264afffe0a' }
			let(:claimable_profile) {
				FactoryGirl.create(:profile, invitation_email: 'Montserrat@Caballe.com', invitation_token: token)
			}
		
			before(:each) do
				claimable_profile.reload.user = nil
				claimable_profile.save
			end
		
			context "as provider with no profile" do
				before(:each) do
					provider.reload.profile = nil
					provider.save
				end
			
				it "successfully attaches the profile with the given token to the current user" do
					get :claim_profile, token: token
					provider.reload.profile.should == claimable_profile
				end
		
				it "redirects to profile view page upon successful claim" do
					get :claim_profile, token: token
					response.should redirect_to(claim_profile_tracking_parameter.merge controller: 'profiles', action: 'view_my_profile')
				end
		
				it "redirects to home page when claim fails" do
					get :claim_profile, token: 'bad-token'
					response.should redirect_to root_url claim_profile_tracking_parameter
					flash[:alert].should_not be_nil
				end
			
				it "fails if profile was already claimed" do
					profile = claimable_profile
					profile.user = FactoryGirl.create(:expert_user, email: 'email@hasnotbeentaken.com')
					profile.save
					get :claim_profile, token: profile.invitation_token
					response.should redirect_to root_url claim_profile_tracking_parameter
					flash[:alert].should_not be_nil
				end
			end
		
			context "as provider that already has a profile" do
				it "should ask for confirmation when claiming the profile in the invitation" do
					get :claim_profile, token: token
					response.should redirect_to confirm_claim_profile_url(claim_profile_tracking_parameter.merge claim_token: token)
				end
			
				it "should succeed when forcing the claim to replace existing profile" do
					get :force_claim_profile, token: token
					response.should redirect_to(claim_profile_tracking_parameter.merge controller: 'profiles', action: 'view_my_profile')
					provider.reload.profile.should == claimable_profile
				end
			end
		end

		describe "GET users show" do
			let(:client_user) { FactoryGirl.create :client_user }
		
			context "as an expert_user attempting to access a user account" do
				it "does not render the view" do
					get :show, id: client_user.id
					response.should_not render_template('show')
				end
			end
		end
	end
	
	context "as admin user" do
		let(:admin_user) { FactoryGirl.create :admin_user, email: 'bossy@example.com' }
		let(:bert) { FactoryGirl.create :provider, email: 'bert@example.com' }
		let(:ernie) { FactoryGirl.create :provider, email: 'ernie@example.com' }
		
		before(:each) do
			sign_in admin_user
		end
		
		describe "GET users index" do
			before(:each) do
				bert and ernie
				get :index
			end

			it "renders the view" do
				response.should render_template('index')
			end

			it "assigns @users" do
				assigns[:users].should == User.all
			end
		end
		
		describe "GET users show" do
			before(:each) do
				get :show, id: bert.id
			end
			
			it "renders the view" do
				response.should render_template('show')
			end
			
			it "assigns @user" do
				assigns[:user].should == bert
			end
		end
	end
end
