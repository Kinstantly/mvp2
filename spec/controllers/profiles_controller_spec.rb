require 'spec_helper'

def destroys_unattached_profile
	id = FactoryGirl.create(:profile).id
	delete :destroy, id: id
	expect(response).to redirect_to(controller: 'profiles', action: 'admin')
	expect(Profile.find_by_id(id)).to be_nil
end

def protects_attached_profile
	profile = FactoryGirl.create(:profile)
	id = profile.id
	user = FactoryGirl.create(:expert_user)
	user.profile = profile
	user.save
	delete :destroy, id: id
	expect(response).to redirect_to(root_path)
	expect(Profile.find_by_id(id)).not_to be_nil
end

describe ProfilesController, :type => :controller do
	let(:photo_url) { 'https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png' }
	
	context "as site visitor attempting to access a published profile" do
		before(:example) do
			@profile = FactoryGirl.create(:published_profile)
		end
		
		describe "GET 'show'" do
			before(:example) do
				get :show, id: @profile.id
			end
			
			it "renders the view" do
				expect(response).to render_template('show')
			end
			
			it "assigns @profile" do
				expect(assigns[:profile]).to eq @profile
			end
		end
		
		describe "GET 'edit'" do
			it "can not render the view" do
				get :edit, id: @profile.id
				expect(response).not_to render_template('edit')
			end
		end
	end
	
	context "as site visitor attempting to access an unpublished profile" do
		before(:example) do
			@profile = FactoryGirl.create(:unpublished_profile)
		end
		
		describe "GET 'show'" do
			it "can not render the view" do
				get :show, id: @profile.id
				expect(response).not_to render_template('show')
			end
		end
		
		describe "GET 'edit'" do
			it "can not render the view" do
				get :edit, id: @profile.id
				expect(response).not_to render_template('edit')
			end
		end
	end
	
	context "as a site visitor attempting to update a profile" do
		describe "PUT 'update'" do
			it "cannot update the profile" do
				id = FactoryGirl.create(:profile).id
				headline = 'Koji Tano'
				put :update, id: id, profile: FactoryGirl.attributes_for(:profile, headline: headline)
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: id)
				expect(Profile.find_by_id(id).headline).not_to eq headline
			end
		end
		describe "POST 'photo_update'", :photo_upload => true do
			it "cannot update profile photo", :photo_upload => true do
				id = FactoryGirl.create(:profile).id
				@photo_file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/assets/profile_photo_test_under1MB.jpg'), 'image/png')
				post :photo_update, id: id, file: @photo_file
				expect(response.status).to eq(302)
				expect(Profile.find_by_id(id).profile_photo.original_filename).to_not eq("profile_photo_test_under1MB.jpg")
				@photo_file.close
			end
		end
	end
	
	context "as a site visitor attempting to delete a profile" do
		describe "DELETE 'destroy'" do
			it "should not destroy a profile" do
				id = FactoryGirl.create(:profile).id
				delete :destroy, id: id
				expect(response).to redirect_to(new_user_session_path)
				expect(Profile.find_by_id(id)).not_to be_nil
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
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: id)
				expect(Profile.find_by_id(id).headline).not_to eq headline
			end
		end

		describe "POST 'photo_update'", :photo_upload => true do
			it "cannot update profile photo", :photo_upload => true do
				id = FactoryGirl.create(:profile).id
				@photo_file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/assets/profile_photo_test_under1MB.jpg'), 'image/png')
				post :photo_update, id: id, file: @photo_file
				expect(response.status).to eq(302)
				expect(Profile.find_by_id(id).profile_photo.original_filename).to_not eq("profile_photo_test_under1MB.jpg")
				@photo_file.close
			end
		end
		
		describe "DELETE 'destroy'" do
			it "should not destroy a profile" do
				id = FactoryGirl.create(:profile).id
				delete :destroy, id: id
				expect(response).to redirect_to(root_path)
				expect(Profile.find_by_id(id)).not_to be_nil
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
					expect(response).not_to render_template('edit')
				end
			end
		end
		
		describe "GET 'view_my_profile'" do
			it "renders show" do
				get :view_my_profile
				expect(response).to render_template('show')
			end
			
			context "ensures the provider has a profile" do
				before(:example) do
					me.profile.destroy
					get :view_my_profile
				end
			
				it "creates a profile if needed" do
					expect(assigns[:profile]).not_to be_nil
					expect(assigns[:profile].user).to eq me
				end
			
				it "creates a published profile" do
					expect(assigns[:profile]).not_to be_nil
					expect(assigns[:profile].is_published).to be_truthy
				end
			end
		end
		
		describe "GET 'edit_my_profile'" do
			it "renders edit" do
				get :edit_my_profile
				expect(response).to render_template('edit')
			end
			
			context "ensures the provider has a profile" do
				before(:example) do
					me.profile.destroy
					get :edit_my_profile
				end
			
				it "creates a profile if needed" do
					expect(assigns[:profile]).not_to be_nil
					expect(assigns[:profile].user).to eq me
				end
			
				it "creates a published profile" do
					expect(assigns[:profile]).not_to be_nil
					expect(assigns[:profile].is_published).to be_truthy
				end
			end
		end
		
		describe "PUT 'formlet_update'" do
			it "successfully updates the profile via a formlet" do
				put :formlet_update, id: my_profile_id, formlet: 'summary', profile: {summary: 'A short story.'}
				expect(response).to render_template('formlet')
			end
			
			it "successfully updates a profile attribute via a formlet" do
				attrs = {summary: 'A short story.'}
				put :formlet_update, id: my_profile_id, formlet: 'summary', profile: attrs
				expect(assigns[:profile].summary).to eq attrs[:summary]
			end
			
			it "cannot update a profile I don't own" do
				put :formlet_update, id: other_published_profile_id, formlet: 'summary', profile: {summary: 'A short story.'}
				expect(response).not_to render_template('formlet')
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

			it "fails to update widget code" do
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'summary', profile: {widget_code: '<a>some code</a>'}
				}.to raise_error(/protected attributes/i)
			end
		end
		
		describe "DELETE 'destroy'" do
			it "should not destroy another profile" do
				id = other_profile_id
				delete :destroy, id: id
				expect(response).to redirect_to(root_path)
				expect(Profile.find_by_id(id)).not_to be_nil
			end
			
			it "should not destroy my profile" do
				id = my_profile_id
				delete :destroy, id: id
				expect(response).to redirect_to(root_path)
				expect(Profile.find_by_id(id)).not_to be_nil
			end
		end
		
		describe "PUT 'update'" do
			let(:attrs) { {first_name: 'Billie Jean'} }
			
			it "should not update another profile" do
				id = other_profile_id
				put :update, id: id, profile: attrs
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: id)
				expect(flash[:alert]).not_to be_nil
			end
			
			it "should not update my profile" do
				id = my_profile_id
				put :update, id: id, profile: attrs
				expect(response).not_to redirect_to(controller: 'profiles', action: 'show', id: id)
				expect(flash[:alert]).not_to be_nil
			end
			
			it "should not update a profile attribute via this action" do
				put :update, id: my_profile_id, profile: attrs
				expect(assigns[:profile].first_name).not_to eq attrs[:first_name]
			end
		end

		describe "POST 'photo_update'", :photo_upload => true do
			before(:context) do
				@photo_file = Rack::Test::UploadedFile.new(
					Rails.root.join('spec/fixtures/assets/profile_photo_test_under1MB.jpg'), 'image/png')
			end
			it "successfully uploads profile photo" do
				id = my_profile_id
				post :photo_update, id: id, file: @photo_file
				@profile = Profile.find_by_id(id)
				expect(response).to be_success
				expect(@profile.profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include("profile_photo_test_under1MB.jpg")
				@profile.profile_photo.destroy
				@profile.save
			end

			it "successfully imports profile photo from url" do
				id = my_profile_id
				post :photo_update, id: id, source_url: photo_url
				@profile = Profile.find_by_id(id)
				expect(response).to be_success
				expect(@profile.profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include(@profile.profile_photo.url(:original))
				@profile.profile_photo.destroy
				@profile.save
			end

			it "cannot update profile photo of a profile I don't own" do
				id = other_profile_id
				post :photo_update, id: id, file: @photo_file
				expect(response.status).to eq(302)
				expect(Profile.find_by_id(id).profile_photo.original_filename).to_not eq("profile_photo_test_under1MB.jpg")
			end
			after(:context) do
				@photo_file.close
			end
		end
		
		describe "GET 'services_info'" do
			before(:example) do
				get :services_info, id: my_profile_id, format: :json
			end
			
			it "returns JSON" do
				expect(response.headers['Content-Type']).to include('application/json')
			end
			
			it "returns association information about the categories, services, and specialties attached to this profile" do
				expect(response.body).to include(me.profile.services.first.name)
				expect(response.body).to include(me.profile.specialties.first.name)
			end
		end
		
		describe "GET 'show_tab'" do
			before(:example) do
				get :show_tab, id: my_profile_id
			end
			
			it "returns HTML" do
				expect(response.headers['Content-Type']).to include('text/html')
			end
			
			it "returns the provider profile" do
				expect(assigns[:profile]).to eq me.profile
			end
		end
		
		describe "GET 'edit_tab'" do
			before(:example) do
				get :edit_tab, id: my_profile_id
			end
			
			it "returns HTML" do
				expect(response.headers['Content-Type']).to include('text/html')
			end
			
			it "returns the provider profile" do
				expect(assigns[:profile]).to eq me.profile
			end
		end
	end
	
	context "as admin user" do
		before (:each) do
			@bossy = FactoryGirl.create(:admin_user, email: 'bossy@example.com')
			sign_in @bossy
		end

		describe "GET 'index'" do
			before(:example) do
				@eddie = FactoryGirl.create(:expert_user, email: 'eddie@example.com')
				get :index
			end
		
			it "renders the view" do
				expect(response).to render_template('index')
			end
		
			it "assigns @profiles" do
				expect(assigns[:profiles]).to eq Profile.all
			end
		end
	
		describe "GET 'new'" do
			before(:example) do
				get :new
			end
		
			it "renders the view" do
				expect(response).to render_template('new')
			end
		
			it "assigns @profile" do
				expect(assigns[:profile]).not_to be_nil
			end
		end
	
		describe "POST 'create'" do
			before(:example) do
				@profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
			end
		
			it "successfully creates the profile" do
				post :create, profile: @profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				expect(flash[:notice]).not_to be_nil
			end
		
			it "can create the profile with no last name" do
				@profile_attrs[:last_name] = ''
				post :create, profile: @profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				expect(flash[:notice]).not_to be_nil
			end
		end
	
		describe "GET 'edit'" do
			before(:example) do
				@profile = FactoryGirl.create(:profile)
				get :edit, id: @profile.id
			end
		
			it "renders the view" do
				expect(response).to render_template('edit')
			end
		
			it "assigns @profile" do
				expect(assigns[:profile]).to eq @profile
			end
			
			it "ensures the profile has a location record to edit or fill in" do
				expect(assigns[:profile].locations.size).to be >= 1
			end
		end
	
		describe "PUT 'update'" do
			before(:example) do
				@profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
				FactoryGirl.create(:profile)
				@profile = Profile.all.first
			end
		
			it "successfully updates the profile" do
				put :update, id: @profile.id, profile: @profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: @profile.id)
				expect(flash[:notice]).not_to be_nil
			end
		
			it "can update the profile with no last name" do
				@profile_attrs[:last_name] = ''
				put :update, id: @profile.id, profile: @profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: @profile.id)
				expect(flash[:notice]).not_to be_nil
			end
		end

		describe "POST 'photo_update'", :photo_upload => true do
			before(:example) do
				@profile = FactoryGirl.create(:profile)
			end
			it "successfully uploads profile photo", :photo_upload => true do
				id = @profile.id
				@photo_file = Rack::Test::UploadedFile.new(
					Rails.root.join('spec/fixtures/assets/profile_photo_test_under1MB.jpg'), 'image/png')
				post :photo_update, id: id, file: @photo_file
				expect(response).to be_success
				expect(Profile.find_by_id(id).profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include("profile_photo_test_under1MB.jpg")
				@photo_file.close
				@profile.profile_photo.destroy
				@profile.save
			end
			it "successfully imports profile photo from url" do
				id = @profile.id
				post :photo_update, id: id, source_url: photo_url
				@profile = Profile.find_by_id(id)
				expect(response).to be_success
				expect(@profile.profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include(@profile.profile_photo.url(:original))
				@profile.profile_photo.destroy
				@profile.save	
			end
			after(:example) do
				#delete uploaded photo
				@profile.profile_photo.destroy
				@profile.save
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
				expect(response).to render_template('index')
			end
		end
	
		describe "GET 'new'" do
			it "renders the view" do
				get :new
				expect(response).to render_template('new')
			end
		end
	
		describe "POST 'create'" do
			it "successfully creates the profile" do
				@profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
				post :create, profile: @profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				expect(flash[:notice]).not_to be_nil
			end
			
			it "successfully creates the profile from the admin page" do
				post :create, profile: FactoryGirl.attributes_for(:profile), admin: true
				expect(response).to redirect_to(controller: 'profiles', action: 'edit', id: assigns[:profile].id)
				expect(flash[:notice]).not_to be_nil
			end
		end
	
		describe "GET 'edit'" do
			it "renders the view" do
				@profile = FactoryGirl.create(:profile)
				get :edit, id: @profile.id
				expect(response).to render_template('edit')
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
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: @profile.id)
				expect(flash[:notice]).not_to be_nil
			end
		end

		describe "POST 'photo_update'", :photo_upload => true do
			before(:example) do
				@profile = FactoryGirl.create(:profile)
			end
			it "successfully uploads profile photo" do
				id = @profile.id
				@photo_file = Rack::Test::UploadedFile.new(
					Rails.root.join('spec/fixtures/assets/profile_photo_test_under1MB.jpg'), 
					'image/png')
				@profile.profile_photo = @photo_file
				post :photo_update, id: id, file: @photo_file
				expect(response).to be_success
				expect(Profile.find_by_id(id).profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include("profile_photo_test_under1MB.jpg")
			end
			it "successfully imports profile photo from url" do
				id = @profile.id
				post :photo_update, id: id, source_url: photo_url
				@profile = Profile.find_by_id(id)
				expect(response).to be_success
				expect(@profile.profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include(@profile.profile_photo.url(:original))
			end
			it "should not upload empty file" do
				post :photo_update, id: @profile.id, file: ''
				expect(response.status).to eq(400)
			end
			it "should not upload file over 5MB in size" do
				@photo_file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/assets/6MB.jpg'))
				@profile.profile_photo = @photo_file
				post :photo_update, id: @profile.id, file: @photo_file
				expect(response).to be_success
				expect(response.body).to include(I18n.t("controllers.profiles.profile_photo_filesize_error"))
			end
			it "should not upload non-image file" do
				#no content type meta-data set -> assuming invalid file type
				@photo_file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/assets/profile_photo_test_under1MB.jpg'))
				@profile.profile_photo = @photo_file
				post :photo_update, id: @profile.id, file: @photo_file
				expect(response).to be_success
				expect(response.body).to include(I18n.t("controllers.profiles.profile_photo_filetype_error"))
			end
			after(:example) do
				#close source photo
				@photo_file.close if @profile_file
				#delete uploaded photo
				@profile.profile_photo.destroy
				@profile.save
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
		
		it "should add two locations", geocoding_api: true, internet: true do
			city_state = {city: 'San Francisco', region: 'CA'}
			location_1_attrs = FactoryGirl.attributes_for(:location, {address1: '1398 Haight St.'}.merge(city_state))
			location_2_attrs = FactoryGirl.attributes_for(:location, {address1: '1855 Haight St.'}.merge(city_state))
			profile = FactoryGirl.create(:profile)
			put :update, id: profile.id, profile: FactoryGirl.attributes_for(:profile, locations_attributes: {
				'0' => location_1_attrs, '1' => location_2_attrs
			})
			expect(response).to redirect_to(controller: 'profiles', action: 'show', id: profile.id)
			expect(assigns[:profile].locations.size).to eq 2
			addresses = [location_1_attrs[:address1], location_2_attrs[:address1]]
			expect(addresses.include?(assigns[:profile].locations[0].address1)).to be_truthy
			expect(addresses.include?(assigns[:profile].locations[1].address1)).to be_truthy
		end
	end
	
	context "for a search engine crawler" do
		before(:example) do
			@published_profile = FactoryGirl.create(:published_profile, last_name: 'Garanca')
			@unpublished_profile = FactoryGirl.create(:unpublished_profile, last_name: 'Netrebko')
			get :link_index
		end
		
		it "should assign published profiles" do
			expect(assigns[:profiles].include?(@published_profile)).to be_truthy
		end
		
		it "should not assign unpublished profiles" do
			expect(assigns[:profiles].include?(@unpublished_profile)).not_to be_truthy
		end
	end
	
	context "as a site visitor searching for a profile" do
		before(:example) do
			@published_profile = FactoryGirl.create(:published_profile, last_name: 'Garanca')
			@unpublished_profile = FactoryGirl.create(:unpublished_profile, last_name: 'Netrebko')
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show search results" do
			get :search, query: @published_profile.last_name
			expect(response).to render_template(:search_results)
		end
		
		it "should assign search results" do
			get :search, query: @published_profile.last_name
			expect(assigns[:search].results.size).to be >= 1
		end
		
		context "visitor is not known" do
			it "should assign published profiles" do
				get :search, query: @published_profile.last_name
				expect(assigns[:search].results.include?(@published_profile)).to be_truthy
			end
			
			it "should not assign unpublished profiles" do
				get :search, query: @unpublished_profile.last_name
				expect(assigns[:search].results.include?(@unpublished_profile)).not_to be_truthy
			end
		end
		
		context "visitor is a profile editor" do
			before(:example) do
				@profile_editor = FactoryGirl.create(:profile_editor, email: 'editor@example.com')
				sign_in @profile_editor
			end
			
			it "should assign unpublished profiles" do
				get :search, query: @unpublished_profile.last_name
				expect(assigns[:search].results.include?(@unpublished_profile)).to be_truthy
			end
		end
		
		context "search restricted by search area tag", geocoding_api: true, internet: true do
			before(:example) do
				tag = FactoryGirl.create(:search_area_tag, name: 'San Francisco')
				loc = FactoryGirl.create(:location, search_area_tag: tag)
				last_name = @published_profile.last_name
				@published_sf_profile = FactoryGirl.create(:published_profile, last_name: last_name, locations: [loc])
				Profile.reindex
				Sunspot.commit
				get :search, query: last_name, search_area_tag_id: tag.id
			end
			
			it "should assign profiles that have the search area tag" do
				expect(assigns[:search].results.include?(@published_sf_profile)).to be_truthy
			end
			
			it "should not assign profiles that do not have the search area tag" do
				expect(assigns[:search].results.include?(@published_profile)).not_to be_truthy
			end
		end
	end
	
	context "as a site visitor searching by distance", geocoding_api: true, internet: true do
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
		
		before(:example) do
			bear_profile and rr_profile
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show the nearest provider at the top when searching by postal code" do
			get :search, query: 'river brewing co', postal_code: bear_location.postal_code
			expect(assigns[:search].results.size).to eq 2
			expect(assigns[:search].results.first).to eq bear_profile
			expect(assigns[:search].results.second).to eq rr_profile
		end
		
		it "should show the nearest provider at the top when searching by city and state" do
			get :search, query: 'river brewing co', city: bear_location.city, region: bear_location.region
			expect(assigns[:search].results.size).to eq 2
			expect(assigns[:search].results.first).to eq bear_profile
			expect(assigns[:search].results.second).to eq rr_profile
		end
		
		it "should show the nearest provider at the top when searching by service and postal code" do
			get :search, service_id: service.id, postal_code: rr_location.postal_code
			expect(assigns[:search].results.size).to eq 2
			expect(assigns[:search].results.first).to eq rr_profile
			expect(assigns[:search].results.second).to eq bear_profile
		end
		
		context "using address option" do
			it "should show the nearest provider at the top when searching by postal code" do
				get :search, query: 'river brewing co', address: bear_location.postal_code
				expect(assigns[:search].results.size).to eq 2
				expect(assigns[:search].results.first).to eq bear_profile
				expect(assigns[:search].results.second).to eq rr_profile
			end
		
			it "should show the nearest provider at the top when searching by city and state" do
				get :search, query: 'river brewing co', address: "#{bear_location.city}, #{bear_location.region}"
				expect(assigns[:search].results.size).to eq 2
				expect(assigns[:search].results.first).to eq bear_profile
				expect(assigns[:search].results.second).to eq rr_profile
			end
		
			it "should show the nearest provider at the top when searching by city, state, and postal code" do
				get :search, query: 'river brewing co', address: "#{bear_location.city}, #{bear_location.region} #{bear_location.postal_code}"
				expect(assigns[:search].results.size).to eq 2
				expect(assigns[:search].results.first).to eq bear_profile
				expect(assigns[:search].results.second).to eq rr_profile
			end
		
			it "should show the nearest provider at the top when searching by service and postal code" do
				get :search, service_id: service.id, address: rr_location.postal_code
				expect(assigns[:search].results.size).to eq 2
				expect(assigns[:search].results.first).to eq rr_profile
				expect(assigns[:search].results.second).to eq bear_profile
			end
		end
	end
	
	context "paginated search" do
		before(:example) do
			FactoryGirl.create_list(:published_profile, 10, company_name: 'Magnolia Gastropub and Brewery')
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show 4 results on the first page" do
			get :search, query: 'magnolia', per_page: '4'
			expect(assigns[:search].results.size).to eq 4
		end
		
		it "should show 2 results on the third page" do
			get :search, query: 'magnolia', per_page: '4', page: 3
			expect(assigns[:search].results.size).to eq 2
		end
	end
	
	context "as a site visitor searching by service" do
		let(:service) { FactoryGirl.create :service, name: 'Brew Master' }
		let(:profile_with_service) { FactoryGirl.create :published_profile, services: [service] }
		let(:profile_with_name) { FactoryGirl.create :published_profile, headline: service.name }
		
		before(:example) do
			profile_with_name and profile_with_service
			Profile.reindex
			Sunspot.commit
		end
		
		it "profiles with the service assigned to them should be listed first" do
			get :search, service_id: service.id
			expect(assigns[:search].results.size).to eq 2
			expect(assigns[:search].results.first).to eq profile_with_service
			expect(assigns[:search].results.second).to eq profile_with_name
		end
	end
	
	context "null search results" do
		before(:example) do
			FactoryGirl.create :published_profile, first_name: 'Maria', last_name: 'Callas'
			FactoryGirl.create :published_profile, first_name: 'Cesare', last_name: 'Valletti'
		end
		
		it "should return no results if no search query is supplied" do
			get :search, query: ''
			expect(assigns[:search].results.size).to eq 0
		end
	end
	
	context "sending invitation to claim a profile" do
		let(:editor) { FactoryGirl.create(:admin_user, email: 'editor@example.com') }
		let(:profile) { FactoryGirl.create(:profile) }
		let(:recipient) { 'la@stupenda.com' }
		let(:subject) { 'Claim your profile' }
		let(:body) { 'We are inviting you to claim your profile.' }
		let(:parameters) { 
			{
				id: profile.id,
				subject: subject,
				body: body,
				profile: {invitation_email: recipient}
			}
		}
		
		context "as an admin user" do
			before (:each) do
				sign_in editor
				get :new_invitation, id: profile.id
			end
		
			it "renders the invitation page" do
				expect(response).to render_template('new_invitation')
			end
			
			context "submit the form to send the invitation" do
				it "should redirect to profile view page if succesful" do
					put :send_invitation, parameters
					expect(response).to redirect_to(controller: 'profiles', action: 'show', id: profile.id)
				end
				
				it "should render the invitation page if failed" do
					put :send_invitation, parameters.merge(profile: {invitation_email: 'nonsense'})
					expect(response).to render_template('new_invitation')
					expect(assigns[:profile].error_on(:invitation_email).size).to eq 1
				end
			end
		end
		
		it "should fail if the profile was already claimed" do
			expert_with_profile = FactoryGirl.create(:expert_user)
			sign_in editor
			put :send_invitation, parameters.merge(id: expert_with_profile.profile.id)
			expect(response).to render_template('new_invitation')
			expect(flash[:alert]).not_to be_nil
		end
	end
	
	context "rating published profiles" do
		let(:profile_to_rate) { FactoryGirl.create(:published_profile) }
		
		before(:example) do
			Profile.find(profile_to_rate.id).ratings.each &:destroy
		end
		
		it "should rate a profile" do
			parent = FactoryGirl.create(:parent)
			sign_in parent
			post :rate, id: profile_to_rate.id, score: '2'
			profile = Profile.find profile_to_rate.id
			expect(profile.ratings.size).to eq 1
			expect(profile.ratings.find_by_rater_id(parent.id).score).to eq 2
		end
		
		it "should fail to rate if not signed in" do
			post :rate, id: profile_to_rate.id, score: '2'
			expect(profile_to_rate.reload.ratings.size).to eq 0
		end
		
		it "redirects to the member sign-up page if not signed in" do
			post :rate, id: profile_to_rate.id, score: '2'
			expect(response).to redirect_to member_sign_up_path
		end
		
		it "should fail to rate the rater's profile" do
			sign_in FactoryGirl.create(:provider, profile: profile_to_rate)
			post :rate, id: profile_to_rate.id, score: '2'
			expect(profile_to_rate.reload.ratings.size).to eq 0
		end
		
		it "should remove a rating" do
			sign_in FactoryGirl.create(:parent)
			post :rate, id: profile_to_rate.id, score: '2'
			expect(profile_to_rate.reload.ratings.size).to eq 1
			post :rate, id: profile_to_rate.id
			expect(profile_to_rate.reload.ratings.size).to eq 0
		end
	end
	
	it "should fail to rate an unpublished profile" do
		profile = FactoryGirl.create(:unpublished_profile)
		sign_in FactoryGirl.create(:parent)
		post :rate, id: profile.id, score: '2'
		expect(profile.reload.ratings.size).to eq 0
	end
	
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
		
		it "renders the view when signed in as an admin user" do
			sign_in FactoryGirl.create(:admin_user)
			get :admin
			expect(response).to render_template('admin')
		end
	end
	
	context "when running as a private site", private_site: true do
		let(:published_profile) { FactoryGirl.create(:published_profile) }
		let(:public_profile_on_private_site) { FactoryGirl.create(:public_profile_on_private_site) }
		
		describe "GET 'show'" do
			it "redirects to the sign-up page" do
				get :show, id: published_profile.id
				expect(response).to redirect_to alpha_sign_up_path
			end
			
			it "shows a profile marked as 'public on private site'" do
				get :show, id: public_profile_on_private_site.id
				expect(response).to render_template('show')
				expect(assigns[:profile]).to eq public_profile_on_private_site
			end
			
			it "does not show an unpublished profile marked as 'public on private site'" do
				public_profile_on_private_site.is_published = false
				public_profile_on_private_site.save
				get :show, id: public_profile_on_private_site.id
				expect(response).to redirect_to alpha_sign_up_path
			end
		end
		
		describe "GET 'search'" do
			it "redirects to the sign-up page" do
				get :search, query: published_profile.last_name
				expect(response).to redirect_to alpha_sign_up_path
			end
		end
		
		describe "GET 'admin'" do
			it "redirects to the sign-up page" do
				get :admin
				expect(response).to redirect_to alpha_sign_up_path
			end
		end
		
		describe "GET 'index'" do
			it "redirects to the sign-up page" do
				get :index
				expect(response).to redirect_to alpha_sign_up_path
			end
		end
		
		describe "GET 'link_index'" do
			it "redirects to the sign-up page" do
				get :link_index
				expect(response).to redirect_to alpha_sign_up_path
			end
		end
	end
end
