require 'spec_helper'

describe UsersController do
	before (:each) do
		@kelly = FactoryGirl.create(:expert_user)
		sign_in @kelly
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
		
		context "as admin user" do
			before(:each) do
				sign_out @kelly
				@bossy = FactoryGirl.create(:admin_user, email: 'bossy@example.com')
				@eddie = FactoryGirl.create(:expert_user, email: 'eddie@example.com')
				sign_in @bossy
				get :index
			end
		
			it "renders the view" do
				response.should render_template('index')
			end
		
			it "assigns @users" do
				assigns[:users].should == User.all
			end
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
			@kelly.profile_help = true
			@kelly.save
		end
		
		it "successfully updates a profile_help attribute" do
			id = @kelly.id
			attrs = {profile_help: false}
			put :update_profile_help, id: id, user: attrs, format: :js
			assigns[:update_succeeded].should be_true
			@kelly.reload.profile_help.should == attrs[:profile_help]
		end
		
		it "should not update user attributes other than profile_help" do
			id = @kelly.id
			email = 'billie@example.com'
			put :update_profile_help,  id: id, user: {email: email}, format: :js
			@kelly.reload.email.should_not == email
			@kelly.unconfirmed_email.should_not == email
		end

		it "cannot update profile_help attribute of another user" do
			other_user_id = FactoryGirl.create(:user).id
			put :update_profile_help, id: other_user_id, user: FactoryGirl.attributes_for(:user, profile_help: true), format: :js
			assigns[:update_succeeded].should be_false
		end
	end
	
	describe "GET claim_profile" do
		before(:each) do
			@token = '2857251c-64e2-11e2-93ca-00264afffe0a'
			@claimable_profile = FactoryGirl.create(:profile, invitation_email: 'Montserrat@Caballe.com', invitation_token: @token)
		end
		
		context "as provider with no profile" do
			before(:each) do
				user = User.find(@kelly.id)
				user.profile = nil
				user.save
			end
			
			it "successfully attaches the profile with the given token to the current user" do
				get :claim_profile, token: @token
				User.find(@kelly.id).profile.should == @claimable_profile
			end
		
			it "redirects to profile view page upon successful claim" do
				get :claim_profile, token: @token
				response.should redirect_to(claim_profile_tracking_parameter.merge controller: 'profiles', action: 'view_my_profile')
			end
		
			it "redirects to home page when claim fails" do
				get :claim_profile, token: 'bad-token'
				response.should redirect_to root_url claim_profile_tracking_parameter
				flash[:alert].should_not be_nil
			end
			
			it "fails if profile was already claimed" do
				profile = @claimable_profile
				profile.user = FactoryGirl.create(:expert_user, email: 'email@hasnotbeentaken.com')
				profile.save
				get :claim_profile, token: profile.invitation_token
				response.should redirect_to root_url claim_profile_tracking_parameter
				flash[:alert].should_not be_nil
			end
		end
		
		context "as provider that already has a profile" do
			it "should ask for confirmation when claiming the profile in the invitation" do
				get :claim_profile, token: @token
				response.should redirect_to confirm_claim_profile_url(claim_profile_tracking_parameter.merge claim_token: @token)
			end
			
			it "should succeed when forcing the claim to replace existing profile" do
				get :force_claim_profile, token: @token
				response.should redirect_to(claim_profile_tracking_parameter.merge controller: 'profiles', action: 'view_my_profile')
				User.find(@kelly.id).profile.should == @claimable_profile
			end
		end
	end

	describe "GET users edit" do
		context "as expert_user attempting to access an edit user view" do
			before(:each) do
				@user = FactoryGirl.create(:client_user)
				get :edit, id: @user.id
			end
			it "does not render the view" do
				response.should_not render_template('edit')
			end
		end
		
		context "as admin user" do
			before(:each) do
				sign_out @kelly
				@bossy = FactoryGirl.create(:admin_user, email: 'bossy@example.com')
				@user = FactoryGirl.create(:client_user)
				sign_in @bossy
				get :edit, id: @user.id
			end
		
			it "renders the view" do
				response.should render_template('edit')
			end
		
			it "assigns @user" do
				assigns[:user].should == User.find(@user.id)
			end
		end
	end

end
