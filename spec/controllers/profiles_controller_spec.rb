require 'spec_helper'

describe ProfilesController do
	context "as site visitor attempting to access a published profile" do
		before(:each) do
			@profile = FactoryGirl.create(:profile, is_published: true)
		end
		
		describe "GET 'show'" do
			before(:each) do
				get :show, id: @profile.id
			end
			
			it "renders the view" do
				response.should render_template('show')
			end
			
			it "assigns @profile" do
				assigns[:profile].should == @profile
			end
		end
		
		describe "GET 'edit'" do
			it "can not render the view" do
				get :edit, id: @profile.id
				response.should_not render_template('edit')
			end
		end
	end
	
	context "as site visitor attempting to access an unpublished profile" do
		before(:each) do
			@profile = FactoryGirl.create(:profile, is_published: false)
		end
		
		describe "GET 'show'" do
			it "can not render the view" do
				get :show, id: @profile.id
				response.should_not render_template('show')
			end
		end
		
		describe "GET 'edit'" do
			it "can not render the view" do
				get :edit, id: @profile.id
				response.should_not render_template('edit')
			end
		end
	end
	
	context "as expert user" do
		before (:each) do
			@me = FactoryGirl.create(:expert_user, email: 'me@example.com')
			sign_in @me
		end
		
		context "attempting to access another profile" do
			before(:each) do
				@profile = FactoryGirl.create(:profile, is_published: true)
			end
		
			describe "GET 'edit'" do
				it "can not render the view" do
					get :edit, id: @profile.id
					response.should_not render_template('edit')
				end
			end
		end
	end
	
	context "as admin user" do
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
			before(:each) do
				@profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
			end
		
			it "successfully creates the profile" do
				post :create, profile: @profile_attrs
				response.should redirect_to(controller: 'profiles', action: 'index')
				flash[:notice].should_not be_nil
			end
		
			it "fails to create the profile with no last name" do
				@profile_attrs[:last_name] = ''
				post :create, profile: @profile_attrs
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
				@profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
				FactoryGirl.create(:profile)
				@profile = Profile.all.first
			end
		
			it "successfully updates the profile" do
				put :update, id: @profile.id, profile: @profile_attrs
				response.should redirect_to(controller: 'profiles', action: 'index')
				flash[:notice].should_not be_nil
			end
		
			it "fails to update the profile with no last name" do
				@profile_attrs[:last_name] = ''
				put :update, id: @profile.id, profile: @profile_attrs
				response.should render_template('edit')
				flash[:alert].should_not be_nil
			end
		end
	end
end
