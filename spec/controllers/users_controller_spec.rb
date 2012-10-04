require 'spec_helper'

describe UsersController do
	before (:each) do
		@kelly = FactoryGirl.create(:user)
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
	
	describe "GET profile_index" do
		before(:each) do
			@eddie = FactoryGirl.create(:user, email: 'eddie@example.com')
			get :index
		end
		
		it "renders the view" do
			response.should render_template('index')
		end
		
		it "assigns @users" do
			assigns[:users].should == User.all
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
		
		it "fails to update the profile" do
			post :update_profile, user: FactoryGirl.attributes_for(:user_with_no_email)
			response.should render_template('edit_profile')
			flash[:alert].should_not be_nil
		end
	end
end
