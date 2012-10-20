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

end
