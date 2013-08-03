require 'spec_helper'

def destroys_unattached_profile
	id = FactoryGirl.create(:profile).id
	delete :destroy, id: id
	response.should redirect_to(controller: 'profiles', action: 'admin')
	Profile.find_by_id(id).should be_nil
end

def protects_attached_profile
	profile = FactoryGirl.create(:profile)
	id = profile.id
	user = FactoryGirl.create(:expert_user)
	user.profile = profile
	user.save
	delete :destroy, id: id
	response.should redirect_to(root_path)
	Profile.find_by_id(id).should_not be_nil
end

describe ProfilesController do
	context "as site visitor attempting to access a published profile" do
		before(:each) do
			@profile = FactoryGirl.create(:published_profile)
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
			@profile = FactoryGirl.create(:unpublished_profile)
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
	
	context "as a site visitor attempting to delete a profile" do
		describe "DELETE 'destroy'" do
			it "should not destroy a profile" do
				id = FactoryGirl.create(:profile).id
				delete :destroy, id: id
				response.should redirect_to(new_user_session_path)
				Profile.find_by_id(id).should_not be_nil
			end
		end
	end
	
	context "as a non-provider member" do
		before (:each) do
			@me = FactoryGirl.create(:client_user, email: 'me@example.com')
			sign_in @me
		end
		
		describe "DELETE 'destroy'" do
			it "should not destroy a profile" do
				id = FactoryGirl.create(:profile).id
				delete :destroy, id: id
				response.should redirect_to(root_path)
				Profile.find_by_id(id).should_not be_nil
			end
		end
	end
	
	context "as a provider" do
		before (:each) do
			@me = FactoryGirl.create(:expert_user, email: 'me@example.com')
			sign_in @me
		end
		
		context "attempting to access another profile" do
			before(:each) do
				@profile = FactoryGirl.create(:published_profile)
			end
		
			describe "GET 'edit'" do
				it "can not render the view" do
					get :edit, id: @profile.id
					response.should_not render_template('edit')
				end
			end
		end
		
		describe "GET 'view_my_profile'" do
			before(:each) do
				get :view_my_profile
			end
			
			it "renders show" do
				response.should render_template('show')
			end
			
			it "creates my profile if needed" do
				assigns[:profile].should_not be_nil
				assigns[:profile].user.should == @me
			end
		end
		
		describe "GET 'edit_my_profile'" do
			before(:each) do
				get :edit_my_profile
			end
			
			it "renders edit" do
				response.should render_template('edit')
			end
			
			it "creates my profile if needed" do
				assigns[:profile].should_not be_nil
				assigns[:profile].user.should == @me
			end
		end
		
		describe "PUT 'formlet_update'" do
			it "successfully updates the profile via a formlet" do
				put :formlet_update, id: @me.profile.id, formlet: 'summary', profile: {summary: 'A short story.'}
				response.should render_template('formlet')
			end
			
			it "cannot update a profile I don't own" do
				@profile = FactoryGirl.create(:published_profile)
				put :formlet_update, id: @profile.id, formlet: 'summary', profile: {summary: 'A short story.'}
				response.should_not render_template('formlet')
			end
		end
		
		describe "DELETE 'destroy'" do
			it "should not destroy another profile" do
				id = FactoryGirl.create(:profile).id
				delete :destroy, id: id
				response.should redirect_to(root_path)
				Profile.find_by_id(id).should_not be_nil
			end
			
			it "should not destroy my profile" do
				id = @me.profile.id
				delete :destroy, id: id
				response.should redirect_to(root_path)
				Profile.find_by_id(id).should_not be_nil
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
				response.should redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				flash[:notice].should_not be_nil
			end
		
			it "can create the profile with no last name" do
				@profile_attrs[:last_name] = ''
				post :create, profile: @profile_attrs
				response.should redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				flash[:notice].should_not be_nil
			end
		end
	
		describe "GET 'edit'" do
			before(:each) do
				@profile = FactoryGirl.create(:profile)
				get :edit, id: @profile.id
			end
		
			it "renders the view" do
				response.should render_template('edit')
			end
		
			it "assigns @profile" do
				assigns[:profile].should == @profile
			end
			
			it "ensures the profile has a location record to edit or fill in" do
				assigns[:profile].should have_at_least(1).location
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
				response.should redirect_to(controller: 'profiles', action: 'show', id: @profile.id)
				flash[:notice].should_not be_nil
			end
		
			it "can update the profile with no last name" do
				@profile_attrs[:last_name] = ''
				put :update, id: @profile.id, profile: @profile_attrs
				response.should redirect_to(controller: 'profiles', action: 'show', id: @profile.id)
				flash[:notice].should_not be_nil
			end
		end
		
		describe "DELETE 'destroy'" do
			it "destroys unattached profile" do
				destroys_unattached_profile
			end
			
			it "should not destroy an attached profile" do
				protects_attached_profile
			end
		end
	end
	
	context "as profile editor" do
		before (:each) do
			@profile_editor = FactoryGirl.create(:profile_editor, email: 'editor@example.com')
			sign_in @profile_editor
		end

		describe "GET 'index'" do
			it "renders the view" do
				@eddie = FactoryGirl.create(:expert_user, email: 'eddie@example.com')
				get :index
				response.should render_template('index')
			end
		end
	
		describe "GET 'new'" do
			it "renders the view" do
				get :new
				response.should render_template('new')
			end
		end
	
		describe "POST 'create'" do
			it "successfully creates the profile" do
				@profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
				post :create, profile: @profile_attrs
				response.should redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				flash[:notice].should_not be_nil
			end
			
			it "successfully creates the profile from the admin page" do
				post :create, profile: FactoryGirl.attributes_for(:profile), admin: true
				response.should redirect_to(controller: 'profiles', action: 'edit', id: assigns[:profile].id)
				flash[:notice].should_not be_nil
			end
		end
	
		describe "GET 'edit'" do
			it "renders the view" do
				@profile = FactoryGirl.create(:profile)
				get :edit, id: @profile.id
				response.should render_template('edit')
			end
		end
	
		describe "PUT 'update'" do
			it "successfully updates the profile" do
				@profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
				@profile = FactoryGirl.create(:profile)
				put :update, id: @profile.id, profile: @profile_attrs
				response.should redirect_to(controller: 'profiles', action: 'show', id: @profile.id)
				flash[:notice].should_not be_nil
			end
		end
		
		describe "DELETE 'destroy'" do
			it "destroys unattached profile" do
				destroys_unattached_profile
			end
			
			it "should not destroy an attached profile" do
				protects_attached_profile
			end
		end
	end
	
	context "for a search engine crawler" do
		before(:each) do
			@published_profile = FactoryGirl.create(:published_profile, last_name: 'Garanca')
			@unpublished_profile = FactoryGirl.create(:unpublished_profile, last_name: 'Netrebko')
			get :link_index
		end
		
		it "should assign published profiles" do
			assigns[:profiles].include?(@published_profile).should be_true
		end
		
		it "should not assign unpublished profiles" do
			assigns[:profiles].include?(@unpublished_profile).should_not be_true
		end
	end
	
	context "as a site visitor searching for a profile" do
		before(:each) do
			@published_profile = FactoryGirl.create(:published_profile, last_name: 'Garanca')
			@unpublished_profile = FactoryGirl.create(:unpublished_profile, last_name: 'Netrebko')
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show search results" do
			get :search, query: @published_profile.last_name
			response.should render_template(:search_results)
		end
		
		it "should assign search results" do
			get :search, query: @published_profile.last_name
			assigns[:search].should have_at_least(1).result
		end
		
		context "visitor is not known" do
			it "should assign published profiles" do
				get :search, query: @published_profile.last_name
				assigns[:search].results.include?(@published_profile).should be_true
			end
			
			it "should not assign unpublished profiles" do
				get :search, query: @unpublished_profile.last_name
				assigns[:search].results.include?(@unpublished_profile).should_not be_true
			end
		end
		
		context "visitor is a profile editor" do
			before(:each) do
				@profile_editor = FactoryGirl.create(:profile_editor, email: 'editor@example.com')
				sign_in @profile_editor
			end
			
			it "should assign unpublished profiles" do
				get :search, query: @unpublished_profile.last_name
				assigns[:search].results.include?(@unpublished_profile).should be_true
			end
		end
		
		context "search restricted by search area tag" do
			before(:each) do
				tag = FactoryGirl.create(:search_area_tag, name: 'San Francisco')
				loc = FactoryGirl.create(:location, search_area_tag: tag)
				last_name = @published_profile.last_name
				@published_sf_profile = FactoryGirl.create(:published_profile, last_name: last_name, locations: [loc])
				Profile.reindex
				Sunspot.commit
				get :search, query: last_name, search_area_tag_id: tag.id
			end
			
			it "should assign profiles that have the search area tag" do
				assigns[:search].results.include?(@published_sf_profile).should be_true
			end
			
			it "should not assign profiles that do not have the search area tag" do
				assigns[:search].results.include?(@published_profile).should_not be_true
			end
		end
	end
	
	context "as a site visitor searching by distance" do
		let(:service) { FactoryGirl.create(:service, name: 'Brew Master') }
		let(:bear_location) {
			FactoryGirl.create(:location, address1: '345 Healdsburg Ave.', city: 'Healdsburg', region: 'CA', postal_code: '95448')
		}
		let(:bear_profile) {
			FactoryGirl.create(:published_profile, company_name: "Bear Republic Brewing Co",
				locations: [bear_location], services: [service])
		}
		let(:rr_location) {
			FactoryGirl.create(:location, address1: '725 4th Street', city: 'Santa Rosa', region: 'CA', postal_code: '95404')
		}
		let(:rr_profile) {
			FactoryGirl.create(:published_profile, company_name: 'Russian River Brewing Co',
				locations: [rr_location], services: [service])
		}
		
		before(:each) do
			bear_profile and rr_profile
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show the nearest provider at the top when searching by postal code" do
			get :search, query: 'river brewing co', postal_code: bear_location.postal_code
			assigns[:search].should have(2).results
			assigns[:search].results.first.should == bear_profile
			assigns[:search].results.second.should == rr_profile
		end
		
		it "should show the nearest provider at the top when searching by city and state" do
			get :search, query: 'river brewing co', city: bear_location.city, region: bear_location.region
			assigns[:search].should have(2).results
			assigns[:search].results.first.should == bear_profile
			assigns[:search].results.second.should == rr_profile
		end
		
		it "should show the nearest provider at the top when searching by service and postal code" do
			get :search, servide_id: service.id, postal_code: rr_location.postal_code
			assigns[:search].should have(2).results
			assigns[:search].results.first.should == rr_profile
			assigns[:search].results.second.should == bear_profile
		end
	end
	
	context "paginated search" do
		before(:each) do
			FactoryGirl.create_list(:published_profile, 10, company_name: 'Magnolia Gastropub and Brewery')
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show 4 results on the first page" do
			get :search, query: 'magnolia', per_page: '4'
			assigns[:search].should have(4).results
		end
		
		it "should show 2 results on the third page" do
			get :search, query: 'magnolia', per_page: '4', page: 3
			assigns[:search].should have(2).results
		end
	end
	
	context "as a site visitor searching by service" do
		let(:service) { FactoryGirl.create :service, name: 'Brew Master' }
		let(:profile_with_service) { FactoryGirl.create :published_profile, services: [service] }
		let(:profile_with_name) { FactoryGirl.create :published_profile, headline: service.name }
		
		before(:each) do
			profile_with_name and profile_with_service
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show profiles with the service assigned to them" do
			get :search, service_id: service.id
			assigns[:search].should have(1).result
			assigns[:search].results.first.should == profile_with_service
		end
		
		it "should ONLY show profiles with the service assigned to them" do
			get :search, service_id: service.id, query: service.name
			assigns[:search].should have(1).result
			assigns[:search].results.first.should == profile_with_service
		end
	end
	
	context "sending invitation to claim a profile" do
		context "as an admin user" do
			before (:each) do
				@editor = FactoryGirl.create(:admin_user, email: 'editor@example.com')
				sign_in @editor
				@profile = FactoryGirl.create(:profile)
				get :new_invitation, id: @profile.id
			end
		
			it "renders the invitation page" do
				response.should render_template('new_invitation')
			end
			
			context "submit the form to send the invitation" do
				it "should redirect to profile view page if succesful" do
					put :send_invitation, id: @profile.id, profile: {invitation_email: 'la@stupenda.com'}
					response.should redirect_to(controller: 'profiles', action: 'show', id: @profile.id)
				end
				
				it "should render the invitation page if failed" do
					put :send_invitation, id: @profile.id, profile: {invitation_email: 'nonsense'}
					response.should render_template('new_invitation')
				end
			end
		end
		
		it "should fail if the profile was already claimed" do
			expert_with_profile = FactoryGirl.create(:expert_user)
			editor = FactoryGirl.create(:admin_user, email: 'editor@example.com')
			sign_in editor
			put :send_invitation, id: expert_with_profile.profile.id, profile: {invitation_email: 'la@stupenda.com'}
			response.should render_template('new_invitation')
			flash[:alert].should_not be_nil
		end
	end
	
	context "rating published profiles" do
		before(:each) do
			@profile = FactoryGirl.create(:published_profile)
		end
		
		it "should rate a profile" do
			sign_in FactoryGirl.create(:client_user)
			post :rate, id: @profile.id, score: '2.0'
			@profile.should have(1).rating
			@profile.ratings.find_by_rater_id(@profile.id).score.should be_within(0.01).of(2.0)
		end
		
		it "should fail to rate if not signed in" do
			post :rate, id: @profile.id, score: '2.0'
			@profile.should have(:no).ratings
		end
		
		it "should fail to rate the rater's profile" do
			sign_in FactoryGirl.create(:expert_user, profile: @profile)
			post :rate, id: @profile.id, score: '2.0'
			@profile.should have(:no).ratings
		end
		
		it "should remove a rating" do
			sign_in FactoryGirl.create(:client_user)
			post :rate, id: @profile.id, score: '2.0'
			@profile.should have(1).rating
			post :rate, id: @profile.id
			@profile.should have(:no).rating
		end
	end
	
	it "should fail to rate an unpublished profile" do
		@profile = FactoryGirl.create(:unpublished_profile)
		sign_in FactoryGirl.create(:client_user)
		post :rate, id: @profile.id, score: '2.0'
		@profile.should have(:no).rating
	end
	
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
		
		it "renders the view when signed in as an admin user" do
			sign_in FactoryGirl.create(:admin_user)
			get :admin
			response.should render_template('admin')
		end
	end
end
