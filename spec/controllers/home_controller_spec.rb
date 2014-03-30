require 'spec_helper'

describe HomeController do
	describe "GET admin" do
		it "does not render the view when not signed in" do
			get :admin
			response.should_not render_template('admin')
		end
		
		it "does not render the view when signed in as an expert user" do
			sign_in FactoryGirl.create(:expert_user)
			get :admin
			response.should_not render_template('admin')
		end
		
		it "does not render the view when signed in as a client user" do
			sign_in FactoryGirl.create(:client_user)
			get :admin
			response.should_not render_template('admin')
		end
		
		context "when signed in as an admin user" do
			before(:each) do
				sign_in FactoryGirl.create(:admin_user)
				get :admin
			end
			
			it "renders the view" do
				response.should render_template('admin')
			end
			
			it "renders the view when running as a private site", private_site: true do
				response.should render_template('admin')
			end
		end
	end
	
	describe "GET 'about'" do
		before(:each) do
			get :about
		end
		
		it "renders the view" do
			response.should render_template 'about'
		end
		
		it "renders the view when running as a private site", private_site: true do
			response.should render_template 'about'
		end
	end
	
	describe "GET 'contact'" do
		before(:each) do
			get :contact
		end
		
		it "renders the view" do
			response.should render_template 'contact'
		end
		
		it "renders the view when running as a private site", private_site: true do
			response.should render_template 'contact'
		end
	end
	
	describe "GET 'privacy'" do
		before(:each) do
			get :privacy
		end
		
		it "renders the view" do
			response.should render_template 'privacy'
		end
		
		it "renders the view when running as a private site", private_site: true do
			response.should render_template 'privacy'
		end
	end
	
	describe "GET 'terms'" do
		before(:each) do
			get :terms
		end
		
		it "renders the view" do
			response.should render_template 'terms'
		end
		
		it "renders the view when running as a private site", private_site: true do
			response.should render_template 'terms'
		end
	end
end
