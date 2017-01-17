require 'spec_helper'

describe HomeController, :type => :controller do
	describe "GET admin" do
		it "does not render the view when not signed in" do
			get :admin
			expect(response).not_to render_template('admin')
		end
		
		it "does not render the view when signed in as an expert user" do
			sign_in FactoryGirl.create(:expert_user)
			get :admin
			expect(response).not_to render_template('admin')
		end
		
		it "does not render the view when signed in as a client user" do
			sign_in FactoryGirl.create(:client_user)
			get :admin
			expect(response).not_to render_template('admin')
		end
		
		context "when signed in as an admin user" do
			before(:example) do
				sign_in FactoryGirl.create(:admin_user)
				get :admin
			end
			
			it "renders the view" do
				expect(response).to render_template('admin')
			end
			
			it "renders the view when running as a private site", private_site: true do
				expect(response).to render_template('admin')
			end
		end
	end
	
	describe "GET 'about'" do
		before(:example) do
			get :about
		end
		
		it "redirects to the About Us page" do
			expect(response).to redirect_to about_page
		end
	end
	
	describe "GET 'contact'" do
		before(:example) do
			get :contact
		end
		
		it "renders the view" do
			expect(response).to render_template 'contact'
		end
		
		it "renders the view when running as a private site", private_site: true do
			expect(response).to render_template 'contact'
		end
	end
	
	describe "GET 'privacy'" do
		before(:example) do
			get :privacy
		end
		
		it "renders the view" do
			expect(response).to render_template 'privacy'
		end
		
		it "renders the view when running as a private site", private_site: true do
			expect(response).to render_template 'privacy'
		end
	end
	
	describe "GET 'terms'" do
		before(:example) do
			get :terms
		end
		
		it "renders the view" do
			expect(response).to render_template 'terms'
		end
		
		it "renders the view when running as a private site", private_site: true do
			expect(response).to render_template 'terms'
		end
	end

	describe "GET 'blog'" do
		before(:example) do
			get :blog
		end

		it "redirects to the blog site" do
			expect(response).to redirect_to blog_url
		end
	end

	describe "GET 'pro'" do
		before(:example) do
			get :pro
		end

		it "redirects to the provider sell page" do
			expect(response).to redirect_to provider_sell_url
		end
	end
end
