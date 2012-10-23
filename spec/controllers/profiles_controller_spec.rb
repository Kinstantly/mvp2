require 'spec_helper'

describe ProfilesController do
	before (:each) do
		@bossy = FactoryGirl.create(:admin_user, email: 'bossy@example.com')
		sign_in @bossy
	end

	describe "GET 'index'" do
		before(:each) do
			@eddie = FactoryGirl.create(:user, email: 'eddie@example.com')
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
end
