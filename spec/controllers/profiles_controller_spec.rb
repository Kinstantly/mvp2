require 'spec_helper'

describe ProfilesController do
	before (:each) do
		@bossy = FactoryGirl.create(:admin_user, email: 'bossy@example.com')
		sign_in @bossy
	end

	describe "GET 'index'" do
		before(:each) do
			@eddie = FactoryGirl.create(:expert_user, email: 'eddie@example.com')
			get :index
		end
		
		it "renders the view" do
			response.should render_template('index')
		end
		
		it "assigns @profiles" do
			assigns[:profiles].should == Profile.all
		end
	end
	
	describe "GET 'new'" do
		before(:each) do
			get :new
		end
		
		it "renders the view" do
			response.should render_template('new')
		end
		
		it "assigns @profile" do
			assigns[:profile].should_not be_nil
		end
	end
	
	describe "POST 'create'" do
		it "successfully creates the profile" do
			post :create, profile: FactoryGirl.attributes_for(:profile)
			response.should redirect_to(controller: 'profiles', action: 'index')
			flash[:notice].should_not be_nil
		end
		
		it "fails to create the profile" do
			post :create, profile: FactoryGirl.attributes_for(:profile, last_name: '')
			response.should render_template('new')
			flash[:alert].should_not be_nil
		end
	end
	
	describe "GET 'edit'" do
		before(:each) do
			FactoryGirl.create(:profile)
			@profile = Profile.all.first
			get :edit, id: @profile.id
		end
		
		it "renders the view" do
			response.should render_template('edit')
		end
		
		it "assigns @profile" do
			assigns[:profile].should == @profile
		end
	end
	
	describe "PUT 'update'" do
		before(:each) do
			FactoryGirl.create(:profile)
			@profile = Profile.all.first
		end
		
		it "successfully updates the profile" do
			put :update, id: @profile.id, profile: FactoryGirl.attributes_for(:profile)
			response.should redirect_to(controller: 'profiles', action: 'index')
			flash[:notice].should_not be_nil
		end
		
		it "fails to update the profile" do
			put :update, id: @profile.id, profile: FactoryGirl.attributes_for(:profile, last_name: '')
			response.should render_template('edit')
			flash[:alert].should_not be_nil
		end
	end
end
