require 'spec_helper'

describe UsersController do
	before (:each) do
		@kelly = FactoryGirl.create(:expert_user)
		sign_in @kelly
	end
	
	describe "GET view_profile" do
		before(:each) do
			get :view_profile
		end
		
		it "renders the view" do
			response.should render_template('view_profile')
		end
		
		it "assigns @profile" do
			assigns[:profile].should == @kelly.profile
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
		before(:each) do
			get :edit_profile
		end
	
		it "renders the view" do
			response.should render_template('edit_profile')
		end
		
		it "assigns @profile" do
			assigns[:profile].should == @kelly.profile
		end
	end
	
	describe "POST update_profile" do
		it "successfully updates the profile" do
			post :update_profile, user: FactoryGirl.attributes_for(:user)
			response.should redirect_to(controller: 'users', action: 'view_profile')
			flash[:notice].should_not be_nil
		end
		
		it "fails to update the profile with no email" do
			post :update_profile, user: FactoryGirl.attributes_for(:user_with_no_email)
			response.should render_template('edit_profile')
			flash[:alert].should_not be_nil
		end
		
		it "fails to self-publish the profile" do
			expect {
				post :update_profile, user: {profile_attributes: {is_published: true}}
			}.to raise_error(/protected attributes/i)
		end
		
		it "fails to update the admin notes" do
			expect {
				post :update_profile, user: {profile_attributes: {admin_notes: 'Sneaky notes'}}
			}.to raise_error(/protected attributes/i)
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
				profile = User.find(@kelly.id).profile
				profile.should_not be_nil
				profile.id.should == @claimable_profile.id
			end
		
			it "redirects to profile view page upon successful claim" do
				get :claim_profile, token: @token
				response.should redirect_to(controller: 'users', action: 'view_profile')
			end
		
			it "does not redirect to profile view page when claim fails" do
				get :claim_profile, token: 'bad-token'
				response.should_not redirect_to(controller: 'users', action: 'view_profile')
				flash[:alert].should_not be_nil
			end
			
			it "fails if profile was already claimed" do
				profile = @claimable_profile
				profile.user = FactoryGirl.create(:expert_user, email: 'email@hasnotbeentaken.com')
				profile.save
				get :claim_profile, token: profile.invitation_token
				response.should_not redirect_to(controller: 'users', action: 'view_profile')
				flash[:alert].should_not be_nil
			end
		end
		
		context "as provider that already has a profile" do
			it "should fail when claiming the profile in the invitation" do
				get :claim_profile, token: @token
				profile = User.find(@kelly.id).profile
				response.should_not redirect_to(controller: 'users', action: 'view_profile')
				flash[:alert].should_not be_nil
			end
		end
	end
end
