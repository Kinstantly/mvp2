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
	
	context "as a site visitor attempting to update a profile" do
		describe "PUT 'update'" do
			it "cannot update the profile" do
				id = FactoryGirl.create(:profile).id
				headline = 'Koji Tano'
				put :update, id: id, profile: FactoryGirl.attributes_for(:profile, headline: headline)
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: id)
				Profile.find_by_id(id).headline.should_not == headline
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
		let(:me) { FactoryGirl.create(:client_user, email: 'me@example.com') }
		
		before (:each) do
			sign_in me
		end
		
		describe "PUT 'update'" do
			it "cannot update a profile" do
				id = FactoryGirl.create(:profile).id
				headline = 'Koji Tano'
				put :update, id: id, profile: FactoryGirl.attributes_for(:profile, headline: headline)
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: id)
				Profile.find_by_id(id).headline.should_not == headline
			end
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
		let(:me) { FactoryGirl.create(:expert_user, email: 'me@example.com') }
		let(:my_profile_id) { me.profile.id }
		let(:other_profile_id) { FactoryGirl.create(:profile).id }
		let(:other_published_profile_id) { FactoryGirl.create(:published_profile).id }
		
		before (:each) do
			sign_in me
		end
		
		context "attempting to access another profile" do
			describe "GET 'edit'" do
				it "can not render the view" do
					get :edit, id: other_published_profile_id
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
				assigns[:profile].user.should == me
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
				assigns[:profile].user.should == me
			end
		end
		
		describe "PUT 'formlet_update'" do
			it "successfully updates the profile via a formlet" do
				put :formlet_update, id: my_profile_id, formlet: 'summary', profile: {summary: 'A short story.'}
				response.should render_template('formlet')
			end
			
			it "successfully updates a profile attribute via a formlet" do
				attrs = {summary: 'A short story.'}
				put :formlet_update, id: my_profile_id, formlet: 'summary', profile: attrs
				assigns[:profile].summary.should == attrs[:summary]
			end
			
			it "cannot update a profile I don't own" do
				put :formlet_update, id: other_published_profile_id, formlet: 'summary', profile: {summary: 'A short story.'}
				response.should_not render_template('formlet')
			end
			
			it "fails to self-publish my profile" do
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'summary', profile: {is_published: true}
				}.to raise_error(/protected attributes/i)
			end
			
			it "fails to update my admin notes" do
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'summary', profile: {admin_notes: 'Sneaky notes'}
				}.to raise_error(/protected attributes/i)
			end
		end
		
		describe "DELETE 'destroy'" do
			it "should not destroy another profile" do
				id = other_profile_id
				delete :destroy, id: id
				response.should redirect_to(root_path)
				Profile.find_by_id(id).should_not be_nil
			end
			
			it "should not destroy my profile" do
				id = my_profile_id
				delete :destroy, id: id
				response.should redirect_to(root_path)
				Profile.find_by_id(id).should_not be_nil
			end
		end
		
		describe "PUT 'update'" do
			let(:attrs) { {first_name: 'Billie Jean'} }
			
			it "should not update another profile" do
				id = other_profile_id
				put :update, id: id, profile: attrs
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: id)
				flash[:alert].should_not be_nil
			end
			
			it "should not update my profile" do
				id = my_profile_id
				put :update, id: id, profile: attrs
				response.should_not redirect_to(controller: 'profiles', action: 'show', id: id)
				flash[:alert].should_not be_nil
			end
			
			it "should not update a profile attribute via this action" do
				put :update, id: my_profile_id, profile: attrs
				assigns[:profile].first_name.should_not == attrs[:first_name]
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
		let(:review_rating_attrs) { {rating_attributes: FactoryGirl.attributes_for(:rating)} }
		
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
		
		it "should add two locations" do
			location_1_attrs = FactoryGirl.attributes_for(:location, address1: 'First house on the right')
			location_2_attrs = FactoryGirl.attributes_for(:location, address1: 'Second house on the left')
			profile = FactoryGirl.create(:profile)
			put :update, id: profile.id, profile: FactoryGirl.attributes_for(:profile, locations_attributes: {
				'0' => location_1_attrs, '1' => location_2_attrs
			})
			response.should redirect_to(controller: 'profiles', action: 'show', id: profile.id)
			assigns[:profile].should have(2).locations
			addresses = [location_1_attrs[:address1], location_2_attrs[:address1]]
			addresses.include?(assigns[:profile].locations[0].address1).should be_true
			addresses.include?(assigns[:profile].locations[1].address1).should be_true
		end
		
		it "should add two reviews" do
			review_1_attrs = FactoryGirl.attributes_for(:review, body: 'This provider is fantastic!',
				reviewer_email: 'reviewer1@example.com', reviewer_username: 'reviewer1').merge(review_rating_attrs)
			review_2_attrs = FactoryGirl.attributes_for(:review, body: 'This provider is adequate.',
				reviewer_email: 'reviewer2@example.com', reviewer_username: 'reviewer2').merge(review_rating_attrs)
			profile = FactoryGirl.create(:profile)
			put :update, id: profile.id, profile: FactoryGirl.attributes_for(:profile, reviews_attributes: {
				'0' => review_1_attrs, '1' => review_2_attrs
			})
			response.should redirect_to(controller: 'profiles', action: 'show', id: profile.id)
			assigns[:profile].should have(2).reviews
			bodies = [review_1_attrs[:body], review_2_attrs[:body]]
			bodies.include?(assigns[:profile].reviews[0].body).should be_true
			bodies.include?(assigns[:profile].reviews[1].body).should be_true
		end
		
		it "should create a record for the reviewer" do
			review_attrs = FactoryGirl.attributes_for(:review, reviewer_email: 'egaranca@mezzo.lv', reviewer_username: 'egaranca').merge(review_rating_attrs)
			profile = FactoryGirl.create(:profile)
			put :update, id: profile.id, profile: FactoryGirl.attributes_for(:profile, reviews_attributes: {
				'0' => review_attrs
			})
			response.should redirect_to(controller: 'profiles', action: 'show', id: profile.id)
			assigns[:profile].should have(1).review
			reviewer = assigns[:profile].reviews.first.reviewer
			reviewer.should_not be_nil
			reviewer.email.should == review_attrs[:reviewer_email]
			reviewer.username.should == review_attrs[:reviewer_username]
		end
		
		it "should create a rating record" do
			review_attrs = FactoryGirl.attributes_for(:review, rating_attributes: {score: 3})
			profile = FactoryGirl.create(:profile)
			put :update, id: profile.id, profile: FactoryGirl.attributes_for(:profile, reviews_attributes: {
				'0' => review_attrs
			})
			response.should redirect_to(controller: 'profiles', action: 'show', id: profile.id)
			assigns[:profile].should have(1).review
			rating = assigns[:profile].reviews.first.rating
			rating.should_not be_nil
			rating.score.should == review_attrs[:rating_attributes][:score]
		end
		
		it "should require a rating score" do
			profile = FactoryGirl.create(:profile)
			put :update, id: profile.id, profile: FactoryGirl.attributes_for(:profile, reviews_attributes: {
				'0' => FactoryGirl.attributes_for(:review)
			})
			response.should render_template('edit')
			assigns[:profile].errors.should be_present
		end
		
		it "should delete a review" do
			profile = FactoryGirl.create(:profile)
			profile.reviews = FactoryGirl.create_list(:review, 1)
			profile.should have(1).review
			put :update, id: profile.id, profile: FactoryGirl.attributes_for(:profile, reviews_attributes: {
				'0' => {'_destroy' => '1', 'id' => profile.reviews.first.id}
			})
			response.should redirect_to(controller: 'profiles', action: 'show', id: profile.id)
			assigns[:profile].should have(:no).reviews
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
		
		it "profiles with the service assigned to them should be listed first" do
			get :search, service_id: service.id
			assigns[:search].should have(2).results
			assigns[:search].results.first.should == profile_with_service
			assigns[:search].results.second.should == profile_with_name
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
