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
	let(:photo_filename) { 'profile_photo_test_under1MB.jpg' }
	let(:photo_file) {
		Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/assets/#{photo_filename}"), 'image/png')
	}
	
	context "as site visitor attempting to access a published profile" do
		let(:profile) { FactoryGirl.create(:published_profile) }
		
		describe "GET 'show'" do
			before(:example) do
				get :show, id: profile.id
			end
			
			it "renders the view" do
				expect(response).to render_template('show')
			end
			
			it "assigns @profile" do
				expect(assigns[:profile]).to eq profile
			end
		end
		
		describe "GET 'edit'" do
			it "can not render the view" do
				get :edit, id: profile.id
				expect(response).not_to render_template('edit')
			end
		end
	end
	
	context "as site visitor attempting to access an unpublished profile" do
		let(:profile) { FactoryGirl.create(:unpublished_profile) }
		
		describe "GET 'show'" do
			it "can not render the view" do
				get :show, id: profile.id
				expect(response).not_to render_template('show')
			end
		end
		
		describe "GET 'edit'" do
			it "can not render the view" do
				get :edit, id: profile.id
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
				post :photo_update, id: id, file: photo_file
				expect(response.status).to eq(302)
				expect(Profile.find_by_id(id).profile_photo.original_filename).to_not eq photo_filename
				photo_file.close
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
				post :photo_update, id: id, file: photo_file
				expect(response.status).to eq(302)
				expect(Profile.find_by_id(id).profile_photo.original_filename).to_not eq photo_filename
				photo_file.close
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
		let(:my_profile) { me.profile }
		let(:my_profile_id) { my_profile.id }
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
				expect(response).to render_template('profiles/formlet_update')
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
				expect(my_profile.is_published).to eq false
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'summary', profile: {is_published: true}
				}.not_to change { my_profile.reload.is_published }
			end
			
			it "fails to update my admin notes" do
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'summary', profile: {admin_notes: 'Sneaky notes'}
				}.not_to change { my_profile.reload.admin_notes }
			end

			it "fails to update widget code" do
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'summary', profile: {widget_code: '<a>some code</a>'}
				}.not_to change { my_profile.reload.widget_code }
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
			it "successfully uploads profile photo" do
				id = my_profile_id
				post :photo_update, id: id, file: photo_file
				profile = Profile.find_by_id(id)
				expect(response).to be_success
				expect(profile.profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include photo_filename
				photo_file.close
				profile.profile_photo.destroy
				profile.save
			end

			it "successfully imports profile photo from url" do
				id = my_profile_id
				post :photo_update, id: id, source_url: photo_url
				profile = Profile.find_by_id(id)
				expect(response).to be_success
				expect(profile.profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include(profile.profile_photo.url(:original))
				profile.profile_photo.destroy
				profile.save
			end

			it "cannot update profile photo of a profile I don't own" do
				id = other_profile_id
				post :photo_update, id: id, file: photo_file
				expect(response.status).to eq(302)
				expect(Profile.find_by_id(id).profile_photo.original_filename).to_not eq photo_filename
				photo_file.close
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
		
		describe 'editing specialties' do
			let(:specialty_names) { ["Mars surf school", "Sandsurfing lessons"] }
			let(:my_profile_with_specialties) {
				my_profile.specialties = specialty_names.map(&:to_specialty)
				my_profile.save!
				my_profile
			}
			
			it 'should replace with two specialties' do
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'specialties', profile: {
						specialty_names: specialty_names
					}
				}.to change { my_profile.reload.specialties.map(&:name).sort }
					.from(my_profile.specialties.map(&:name).sort)
					.to(specialty_names.sort)
			end
			
			it 'should delete a specialty' do
				expect {
					put :formlet_update, id: my_profile_with_specialties.id, formlet: 'specialties', profile: {
						specialty_names: specialty_names.slice(0, 1)
					}
				}.to change { my_profile_with_specialties.reload.specialties.map(&:name).sort }
					.from(my_profile_with_specialties.specialties.map(&:name).sort)
					.to(specialty_names.slice(0, 1).sort)
			end
		end
		
		describe "editing locations", geocoding_api: true, internet: true do
			let(:city_state) { {city: 'San Francisco', region: 'CA'} }
			let(:location_1_attrs) { FactoryGirl.attributes_for(:location, {address1: '1398 Haight St.'}.merge(city_state)) }
			let(:location_2_attrs) { FactoryGirl.attributes_for(:location, {address1: '563 2nd St.'}.merge(city_state)) }
			let(:location_1) { FactoryGirl.create(:location, location_1_attrs) }
			let(:my_profile_with_location_1) { 
				my_profile.locations = [location_1]
				my_profile.save!
				my_profile
			}
			
			it "should add two locations" do
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'locations', profile: FactoryGirl.attributes_for(:profile, locations_attributes: {
						'0' => location_1_attrs, '1' => location_2_attrs
					})
				}.to change { my_profile.reload.locations.size }.by(2)
				addresses = [location_1_attrs[:address1], location_2_attrs[:address1]]
				my_profile.reload.locations.each { |location|
					expect(addresses.include?(location.address1)).to be_truthy
				}
			end
			
			it "should update a location" do
				location = my_profile_with_location_1.locations.first
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'locations', profile: FactoryGirl.attributes_for(:profile, locations_attributes: {
						'0' => location_2_attrs.merge({id: location.id})
					})
				}.to change { location.reload.address1 }.from(location_1_attrs[:address1]).to(location_2_attrs[:address1])
			end
			
			it 'should delete a location' do
				location = my_profile_with_location_1.locations.first
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'locations', profile: FactoryGirl.attributes_for(:profile, locations_attributes: {
						'0' => location_1_attrs.merge({id: location.id, _destroy: '1'})
					})
				}.to change { my_profile_with_location_1.reload.locations.size }.by(-1)
			end
		end
		
		describe 'editing profile announcements' do
			let(:announcement_attrs) {
				FactoryGirl.attributes_for(:profile_announcement, 
					body: 'Legally-imposed culture reduction is cabbage-brained!')
			}
			let(:announcement) { FactoryGirl.create(:profile_announcement, announcement_attrs) }
			let(:my_profile_with_announcement) {
				my_profile.profile_announcements = [announcement]
				my_profile.save!
				my_profile
			}
			
			it "should add an announcement" do
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'announcements', child_formlet: 'announcement_new', profile: FactoryGirl.attributes_for(:profile, profile_announcements_attributes: {
						'0' => announcement_attrs
					})
				}.to change { my_profile.reload.profile_announcements.size }.by(1)
				expect(my_profile.reload.profile_announcements.map(&:body).include?(announcement_attrs[:body])).to be_truthy
			end
			
			it 'should update an announcement' do
				announcement_to_update = my_profile_with_announcement.profile_announcements.first
				new_body = 'Another way of sending fond returns is here!'
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'announcements', child_formlet: 'announcement_0', profile: FactoryGirl.attributes_for(:profile, profile_announcements_attributes: {
						'0' => announcement_attrs.merge({id: announcement_to_update.id, body: new_body})
					})
				}.to change { announcement_to_update.reload.body }.from(announcement_attrs[:body]).to(new_body)
			end
			
			it 'should delete an announcement' do
				announcement_to_delete = my_profile_with_announcement.profile_announcements.first
				expect {
					put :formlet_update, id: my_profile_id, formlet: 'announcements', child_formlet: 'announcement_0', profile: FactoryGirl.attributes_for(:profile, profile_announcements_attributes: {
						'0' => announcement_attrs.merge({id: announcement_to_delete.id, _destroy: '1'})
					})
				}.to change { my_profile_with_announcement.reload.profile_announcements.size }.by(-1)
			end
		end
	end
	
	context "as admin user" do
		let(:bossy) { FactoryGirl.create(:admin_user, email: 'bossy@example.com') }
		
		before (:each) do
			sign_in bossy
		end

		describe "GET 'index'" do
			before(:example) do
				FactoryGirl.create(:expert_user, email: 'eddie@example.com')
				get :index
			end
		
			it "renders the view" do
				expect(response).to render_template('index')
			end
		
			it "assigns @profiles" do
				Profile.all.each do |profile|
					expect(assigns[:profiles]).to include profile
				end
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
			let(:profile_attrs) {
				FactoryGirl.attributes_for(:profile,
					category_ids: ["#{FactoryGirl.create(:category).id}"],
					subcategory_ids: ["#{FactoryGirl.create(:subcategory).id}"],
					service_ids: ["#{FactoryGirl.create(:service).id}"],
					specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
			}
		
			it "successfully creates the profile" do
				post :create, profile: profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				expect(flash[:notice]).not_to be_nil
				expect(assigns[:profile].categories.first).not_to be_nil
				expect(assigns[:profile].subcategories.first).not_to be_nil
				expect(assigns[:profile].services.first).not_to be_nil
				expect(assigns[:profile].specialties.first).not_to be_nil
			end
		
			it "can create the profile with no last name" do
				profile_attrs[:last_name] = ''
				post :create, profile: profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				expect(flash[:notice]).not_to be_nil
			end
		end
	
		describe "GET 'edit'" do
			let(:profile) { FactoryGirl.create(:profile) }
			
			before(:example) do
				get :edit, id: profile.id
			end
		
			it "renders the view" do
				expect(response).to render_template('edit')
			end
		
			it "assigns @profile" do
				expect(assigns[:profile]).to eq profile
			end
			
			it "ensures the profile has a location record to edit or fill in" do
				expect(assigns[:profile].locations.size).to be >= 1
			end
		end
	
		describe "PUT 'update'" do
			let(:profile_attrs) {
				FactoryGirl.attributes_for(:profile,
					category_ids: ["#{FactoryGirl.create(:category).id}"],
					subcategory_ids: ["#{FactoryGirl.create(:subcategory).id}"],
					service_ids: ["#{FactoryGirl.create(:service).id}"],
					specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
			}
			let(:profile) { FactoryGirl.create(:profile) }
			
			it "successfully updates the profile" do
				put :update, id: profile.id, profile: profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: profile.id)
				expect(flash[:notice]).not_to be_nil
				expect(assigns[:profile].categories.first).not_to be_nil
				expect(assigns[:profile].subcategories.first).not_to be_nil
				expect(assigns[:profile].services.first).not_to be_nil
				expect(assigns[:profile].specialties.first).not_to be_nil
			end
		
			it "can update the profile with no last name" do
				profile_attrs[:last_name] = ''
				put :update, id: profile.id, profile: profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: profile.id)
				expect(flash[:notice]).not_to be_nil
			end
		end

		describe "POST 'photo_update'", :photo_upload => true do
			let(:profile) { FactoryGirl.create(:profile) }
			
			it "successfully uploads profile photo", :photo_upload => true do
				id = profile.id
				post :photo_update, id: id, file: photo_file
				expect(response).to be_success
				expect(Profile.find_by_id(id).profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include photo_filename
				photo_file.close
				profile.profile_photo.destroy
				profile.save
			end
			
			it "successfully imports profile photo from url" do
				id = profile.id
				post :photo_update, id: id, source_url: photo_url
				profile = Profile.find_by_id(id)
				expect(response).to be_success
				expect(profile.profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include(profile.profile_photo.url(:original))
				profile.profile_photo.destroy
				profile.save	
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
		let(:profile_editor) { FactoryGirl.create(:profile_editor, email: 'editor@example.com') }
		
		before (:each) do
			sign_in profile_editor
		end

		describe "GET 'index'" do
			it "renders the view" do
				FactoryGirl.create(:expert_user, email: 'eddie@example.com')
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
				profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
				post :create, profile: profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: assigns[:profile].id)
				expect(flash[:notice]).not_to be_nil
				expect(assigns[:profile].categories.first).not_to be_nil
				expect(assigns[:profile].specialties.first).not_to be_nil
			end
			
			it "successfully creates the profile from the admin page" do
				post :create, profile: FactoryGirl.attributes_for(:profile), admin: true
				expect(response).to redirect_to(controller: 'profiles', action: 'edit', id: assigns[:profile].id)
				expect(flash[:notice]).not_to be_nil
			end
		end
	
		describe "GET 'edit'" do
			it "renders the view" do
				profile = FactoryGirl.create(:profile)
				get :edit, id: profile.id
				expect(response).to render_template('edit')
			end
		end
	
		describe "PUT 'update'" do
			it "successfully updates the profile" do
				profile_attrs = 
					FactoryGirl.attributes_for(:profile,
						category_ids: ["#{FactoryGirl.create(:category).id}"],
						specialty_ids: ["#{FactoryGirl.create(:specialty).id}"])
				profile = FactoryGirl.create(:profile)
				put :update, id: profile.id, profile: profile_attrs
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: profile.id)
				expect(flash[:notice]).not_to be_nil
			end
		end

		describe "POST 'photo_update'", :photo_upload => true do
			let(:profile) { FactoryGirl.create(:profile) }
			
			it "successfully uploads profile photo" do
				id = profile.id
				profile.profile_photo = photo_file
				post :photo_update, id: id, file: photo_file
				expect(response).to be_success
				expect(Profile.find_by_id(id).profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include photo_filename
				photo_file.close
				#delete uploaded photo
				profile.profile_photo.destroy
				profile.save
			end
			
			it "successfully imports profile photo from url" do
				id = profile.id
				post :photo_update, id: id, source_url: photo_url
				profile = Profile.find_by_id(id)
				expect(response).to be_success
				expect(profile.profile_photo.url).to_not eq(Profile::DEFAULT_PHOTO_PATH)
				expect(response.body).to include(profile.profile_photo.url(:original))
				#delete uploaded photo
				profile.profile_photo.destroy
				profile.save
			end
			
			it "should not upload empty file" do
				post :photo_update, id: profile.id, file: ''
				expect(response.status).to eq(400)
			end
			
			it "should not upload file over 5MB in size" do
				big_photo_file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/assets/6MB.jpg'))
				profile.profile_photo = big_photo_file
				post :photo_update, id: profile.id, file: big_photo_file
				expect(response).to be_success
				expect(response.body).to include(I18n.t("controllers.profiles.profile_photo_filesize_error"))
				big_photo_file.close
				profile.profile_photo.destroy
				profile.save
			end
			
			it "should not upload non-image file" do
				#no content type meta-data set -> assuming invalid file type
				non_image_file = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/assets/#{photo_filename}"))
				profile.profile_photo = non_image_file
				post :photo_update, id: profile.id, file: non_image_file
				expect(response).to be_success
				expect(response.body).to include(I18n.t("controllers.profiles.profile_photo_filetype_error"))
				non_image_file.close
				profile.profile_photo.destroy
				profile.save
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
		
		describe 'editing specialties' do
			let(:specialty_names) { ["Mars surf school", "Sandsurfing lessons"] }
			let(:profile) { FactoryGirl.create(:profile) }
			let(:profile_with_specialties) {
				profile.specialties = specialty_names.map(&:to_specialty)
				profile.save!
				profile
			}
			
			it 'should add two specialties' do
				specialties_names_before = profile.specialties.map(&:name)
				expect {
					put :update, id: profile.id,
						profile: FactoryGirl.attributes_for(:profile, custom_specialty_names: specialty_names)
				}.to change { profile.reload.specialties.map(&:name).sort }
					.from(specialties_names_before.sort)
					.to((specialties_names_before + specialty_names).uniq.sort)
			end
			
			it 'should delete a specialty' do
				specialties_names_before = profile_with_specialties.specialties.map(&:name)
				kept_specialty = profile_with_specialties.specialties.first
				expect {
					put :update, id: profile_with_specialties.id,
						profile: FactoryGirl.attributes_for(:profile, specialty_ids: [kept_specialty.id])
				}.to change { profile_with_specialties.reload.specialties.map(&:name).sort }
					.from(specialties_names_before.sort)
					.to([kept_specialty.name])
			end
		end
		
		describe "editing locations", geocoding_api: true, internet: true do
			let(:city_state) { {city: 'San Francisco', region: 'CA'} }
			let(:location_1_attrs) { FactoryGirl.attributes_for(:location, {address1: '1398 Haight St.'}.merge(city_state)) }
			let(:location_2_attrs) { FactoryGirl.attributes_for(:location, {address1: '563 2nd St.'}.merge(city_state)) }
			let(:profile) { FactoryGirl.create(:profile) }
			let(:location_1) { FactoryGirl.create(:location, location_1_attrs) }
			let(:profile_with_location_1) { FactoryGirl.create(:profile, locations: [location_1]) }
			
			it "should add two locations" do
				expect {
					put :update, id: profile.id, profile: FactoryGirl.attributes_for(:profile, locations_attributes: {
						'0' => location_1_attrs, '1' => location_2_attrs
					})
				}.to change { profile.reload.locations.size }.by(2)
				expect(response).to redirect_to(controller: 'profiles', action: 'show', id: profile.id)
				addresses = [location_1_attrs[:address1], location_2_attrs[:address1]]
				assigns[:profile].locations.each { |location|
					expect(addresses.include?(location.address1)).to be_truthy
				}
			end
		
			it "should update a location" do
				location = profile_with_location_1.locations.first
				expect {
					put :update, id: profile_with_location_1.id, profile: FactoryGirl.attributes_for(:profile, locations_attributes: {
						'0' => location_2_attrs.merge({id: location.id})
					})
				}.to change { location.reload.address1 }.from(location_1_attrs[:address1]).to(location_2_attrs[:address1])
			end
			
			it 'should delete a location' do
				location = profile_with_location_1.locations.first
				expect {
					put :update, id: profile_with_location_1.id, profile: FactoryGirl.attributes_for(:profile, locations_attributes: {
						'0' => location_1_attrs.merge({id: location.id, _destroy: '1'})
					})
				}.to change { profile_with_location_1.reload.locations.size }.by(-1)
			end
		end
	end
	
	context "for a search engine crawler" do
		let(:published_profile) { FactoryGirl.create(:published_profile, last_name: 'Garanca') }
		let(:unpublished_profile) { FactoryGirl.create(:unpublished_profile, last_name: 'Netrebko') }
		
		before(:example) do
			published_profile and unpublished_profile
			get :link_index
		end
		
		it "should assign published profiles" do
			expect(assigns[:profiles].include?(published_profile)).to be_truthy
		end
		
		it "should not assign unpublished profiles" do
			expect(assigns[:profiles].include?(unpublished_profile)).not_to be_truthy
		end
	end
	
	context "as a site visitor searching for a profile" do
		let(:published_profile) { FactoryGirl.create(:published_profile, last_name: 'Garanca') }
		let(:unpublished_profile) { FactoryGirl.create(:unpublished_profile, last_name: 'Netrebko') }
		
		before(:example) do
			published_profile and unpublished_profile
			Profile.reindex
			Sunspot.commit
		end
		
		it "should show search results" do
			get :search, query: published_profile.last_name
			expect(response).to render_template(:search_results)
		end
		
		it "should assign search results" do
			get :search, query: published_profile.last_name
			expect(assigns[:search].results.size).to be >= 1
		end
		
		context "visitor is not known" do
			it "should assign published profiles" do
				get :search, query: published_profile.last_name
				expect(assigns[:search].results.include?(published_profile)).to be_truthy
			end
			
			it "should not assign unpublished profiles" do
				get :search, query: unpublished_profile.last_name
				expect(assigns[:search].results.include?(unpublished_profile)).not_to be_truthy
			end
		end
		
		context "visitor is a profile editor" do
			let(:profile_editor) { FactoryGirl.create(:profile_editor, email: 'editor@example.com') }
			
			before(:example) do
				sign_in profile_editor
			end
			
			it "should assign unpublished profiles" do
				get :search, query: unpublished_profile.last_name
				expect(assigns[:search].results.include?(unpublished_profile)).to be_truthy
			end
		end
		
		context "search restricted by search area tag", geocoding_api: true, internet: true do
			let(:tag) { FactoryGirl.create(:search_area_tag, name: 'San Francisco') }
			let(:loc) { FactoryGirl.create(:location, search_area_tag: tag) }
			let(:last_name) { published_profile.last_name }
			let(:published_sf_profile) {
				FactoryGirl.create(:published_profile, last_name: last_name, locations: [loc])
			}
			
			before(:example) do
				published_sf_profile
				Profile.reindex
				Sunspot.commit
				get :search, query: last_name, search_area_tag_id: tag.id
			end
			
			it "should assign profiles that have the search area tag" do
				expect(assigns[:search].results.include?(published_sf_profile)).to be_truthy
			end
			
			it "should not assign profiles that do not have the search area tag" do
				expect(assigns[:search].results.include?(published_profile)).not_to be_truthy
			end
		end
	end
	
	context "as a site visitor searching by distance", geocoding_api: true, internet: true do
		let(:service) { FactoryGirl.create(:service, name: 'Brew Master') }
		let(:bear_location) {
			FactoryGirl.create(:location, address1: '345 Healdsburg Ave.', city: 'Healdsburg', region: 'CA', postal_code: '95448', country: 'US')
		}
		let(:bear_profile) {
			FactoryGirl.create(:published_profile, company_name: "Bear Republic Brewing Co",
				locations: [bear_location], services: [service])
		}
		let(:rr_location) {
			FactoryGirl.create(:location, address1: '725 4th Street', city: 'Santa Rosa', region: 'CA', postal_code: '95404', country: 'US')
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
