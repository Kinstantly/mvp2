require 'spec_helper'

describe Profile, :type => :model do
	before(:example) do
		@profile_data ||= {
			first_name: 'Joe', last_name: 'Black', company_name: 'Coffee is Good',
			categories: [FactoryGirl.create(:category, name: 'THERAPISTS & PARENTING COACHES')],
			services: [FactoryGirl.create(:service, name: 'board-certified behavior analyst'),
				FactoryGirl.create(:service, name: 'child/clinical psychologist')],
			specialties: [FactoryGirl.create(:specialty, name: 'behavior'), 
				FactoryGirl.create(:specialty, name: 'choosing a school (pre-K to 12)')]
		}
		@profile = FactoryGirl.build(:profile, @profile_data)
	end
	
	context "name" do
		it "is happy if we set both first and last name" do
			expect(@profile.errors_on(:first_name).size).to eq 0
			expect(@profile.errors_on(:last_name).size).to eq 0
		end
		
		it "is happy if first and last name are NOT set" do
			@profile.first_name = ''
			@profile.last_name = ''
			expect(@profile.errors_on(:first_name).size).to eq 0
			expect(@profile.errors_on(:last_name).size).to eq 0
		end
	end
	
	context "display name" do
		it "contains first, middle, and last name as well as credentials" do
			@profile.middle_name = 'X'
			@profile.credentials = 'BA, MA'
			expect(@profile.display_name).to match /#{@profile.first_name}.*#{@profile.middle_name}.*#{@profile.last_name}.*#{@profile.credentials}/
		end
		
		context "presentable display name" do
			it "is presentable if there is a first name" do
				@profile.last_name = ''
				expect(@profile.display_name_presentable?).to be_truthy
				expect(@profile.presentable_display_name).to be_present
			end

			it "is presentable if there is a last name" do
				@profile.first_name = ''
				expect(@profile.display_name_presentable?).to be_truthy
				expect(@profile.presentable_display_name).to be_present
			end
			
			it "is not presentable if there is no first or last name" do
				@profile.first_name = ''
				@profile.last_name = ''
				expect(@profile.display_name_presentable?).to be_falsey
				expect(@profile.presentable_display_name).not_to be_present
			end
		end
	end
	
	context "company name if present, otherwise display name" do
		it "returns company name if present and first name is present" do
			@profile.last_name = ''
			expect(@profile.company_otherwise_display_name).to eq @profile.company_name
		end
		
		it "returns company name if present and last name is present" do
			@profile.first_name = ''
			expect(@profile.company_otherwise_display_name).to eq @profile.company_name
		end
		
		it "returns display name if company name is not present" do
			@profile.company_name = ''
			expect(@profile.company_otherwise_display_name).to eq @profile.display_name
		end
		
		it "returns empty string if none of company, first, and last name are present" do
			@profile.first_name = ''
			@profile.last_name = ''
			@profile.company_name = ''
			expect(@profile.company_otherwise_display_name).to eq ''
		end
	end
	
	context "display name if present, otherwise company name" do
		it "returns display name if first name is present" do
			@profile.last_name = ''
			expect(@profile.display_name_or_company).to eq @profile.display_name
		end
		
		it "returns display name if last name is present" do
			@profile.first_name = ''
			expect(@profile.display_name_or_company).to eq @profile.display_name
		end
		
		it "returns company name if neither first name nor last name are present" do
			@profile.first_name = ''
			@profile.last_name = ''
			expect(@profile.display_name_or_company).to eq @profile.company_name
		end
	end
	
	context "categories" do
		it "stores a category" do
			expect(@profile.save).to be_truthy
			expect(Profile.find_by_last_name(@profile_data[:last_name]).categories).to eq @profile_data[:categories]
		end
		
		it "does not require a category if not publishing" do
			@profile.is_published = false
			@profile.categories = []
			expect(@profile.errors_on(:categories).size).to eq 0
		end
		
		it "allows more than one category" do
			@profile.categories = @profile_data[:categories]
			@profile.categories << FactoryGirl.create(:category, name: 'MISC.')
			expect(@profile.errors_on(:categories).size).to eq 0
		end
	end
	
	context "services" do
		it "stores multiple services" do
			expect(@profile.save).to be_truthy
			stored_services = Profile.find_by_last_name(@profile_data[:last_name]).services
			@profile_data[:services].each do |svc|
				expect(stored_services.include?(svc)).to be_truthy
			end
		end
		
		context "custom services" do
			it "merges custom services" do
				custom = [@profile_data[:services].first.name, 'story teller']
				@profile.custom_service_names = custom
				expect(@profile.save).to eq true
				profile = Profile.find_by_last_name(@profile_data[:last_name])
				expect(profile.services.size).to eq @profile_data[:services].size + 1
				expect(profile.services.collect(&:name).include?(custom.last)).to be_truthy
			end
			
			it "limits length of name" do
				name = 'a' * Profile::MAX_LENGTHS[:custom_service_names]
				@profile.custom_service_names = [name]
				expect(@profile.error_on(:custom_service_names).size).to eq 0
				@profile.custom_service_names = [name + 'a']
				expect(@profile.error_on(:custom_service_names).size).to eq 1
			end
			
			it "filters out blanks and strips" do
				name = 'Theremin Teacher'
				@profile.custom_service_names = [nil, '', ' ', " #{name} "]
				expect(@profile.errors_on(:custom_service_names).size).to eq 0
				expect(@profile.custom_service_names.size).to eq 1
				expect(@profile.custom_service_names.first).to eq name
			end
		end
	end
	
	context "specialties" do
		it "stores multiple specialties" do
			expect(@profile.save).to be_truthy
			stored_specialties = Profile.find_by_last_name(@profile_data[:last_name]).specialties
			@profile_data[:specialties].each do |spc|
				expect(stored_specialties.include?(spc)).to be_truthy
			end
		end
		
		it "does not require a specialty" do
			@profile.specialties = []
			expect(@profile.errors_on(:specialties).size).to eq 0
		end
		
		it "has a simple array of specialty IDs and names" do
			ids_names = @profile.specialty_ids_names
			specialties_data = @profile_data[:specialties]
			ids_names.each_index do |i|
				expect(specialties_data[i].id).to eq ids_names[i][:id]
				expect(specialties_data[i].name).to eq ids_names[i][:name]
			end
		end
		
		context "specialty names" do
			it "sets specialties by name" do
				names = ['wonderful children', 'parenting support']
				@profile.specialty_names = names
				expect(@profile.save).to eq true
				@profile.reload
				expect(@profile.specialties.size).to eq names.size
				specialty_names = @profile.specialties.collect(&:name)
				names.each do |name|
					expect(specialty_names.include?(name)).to be_truthy
				end
			end
			
			it "does not affect existing specialties if we don't set specialty_names" do
				specialty_count = @profile.specialties.size
				@profile.first_name = 'Norma'
				expect(@profile.save).to eq true
				@profile.reload
				expect(@profile.specialties.size).to eq specialty_count
			end
			
			it "limits length of name" do
				name = 'a' * Profile::MAX_LENGTHS[:specialty_names]
				@profile.specialty_names = [name]
				expect(@profile.error_on(:specialty_names).size).to eq 0
				@profile.specialty_names = [name + 'a']
				expect(@profile.error_on(:specialty_names).size).to eq 1
			end
			
			it "filters out blanks and strips" do
				name = 'theremin instruction'
				@profile.specialty_names = [nil, '', ' ', " #{name} "]
				expect(@profile.errors_on(:specialty_names).size).to eq 0
				expect(@profile.specialty_names.size).to eq 1
				expect(@profile.specialty_names.first).to eq name
			end
		end
		
		context "custom specialties" do
			it "merges custom specialties" do
				custom = [@profile_data[:specialties].first.name, 'parenting support']
				@profile.custom_specialty_names = custom
				expect(@profile.save).to eq true
				profile = Profile.find_by_last_name(@profile_data[:last_name])
				expect(profile.specialties.size).to eq (@profile_data[:specialties].size + 1)
				expect(profile.specialties.collect(&:name).include?(custom.last)).to be_truthy
			end
			
			it "limits length of name" do
				name = 'a' * Profile::MAX_LENGTHS[:custom_specialty_names]
				@profile.custom_specialty_names = [name]
				expect(@profile.error_on(:custom_specialty_names).size).to eq 0
				@profile.custom_specialty_names = [name + 'a']
				expect(@profile.error_on(:custom_specialty_names).size).to eq 1
			end
			
			it "filters out blanks and strips" do
				name = 'theremin instruction'
				@profile.custom_specialty_names = [nil, '', ' ', " #{name} "]
				expect(@profile.errors_on(:custom_specialty_names).size).to eq 0
				expect(@profile.custom_specialty_names.size).to eq 1
				expect(@profile.custom_specialty_names.first).to eq name
			end
		end
		
		it "stores a text description of specialties" do
			@profile.specialties_description = 'methods of parenting, parent/child communication, parenting through separation and divorce'
			expect(@profile.errors_on(:specialties_description).size).to eq 0
		end
	end
	
	context "consultations" do
		it "stores contact options" do
			@profile.consult_by_email = true
			@profile.consult_by_phone = true
			@profile.consult_by_video = false
			@profile.visit_home = true
			@profile.visit_school = false
			expect(@profile.errors_on(:consult_by_email).size).to eq 0
			expect(@profile.errors_on(:consult_by_phone).size).to eq 0
			expect(@profile.errors_on(:consult_by_video).size).to eq 0
			expect(@profile.errors_on(:visit_home).size).to eq 0
			expect(@profile.errors_on(:visit_school).size).to eq 0
		end
		
		it "stores consultation option for providers that offer most or all of their services remotely" do
			@profile.consult_remotely = true
			expect(@profile.errors_on(:consult_remotely).size).to eq 0
		end
	end
	
	context "hours" do
		it "stores a description of hours" do
			@profile.hours = "9:00 AM to 5:00 PM, MWF\n11:00 AM to 3:00 PM, TuTh"
			expect(@profile.errors_on(:hours).size).to eq 0
		end
		
		it "has checkable options" do
			@profile.evening_hours_available = true
			@profile.weekend_hours_available = true
			expect(@profile.errors_on(:evening_hours_available).size).to eq 0
			expect(@profile.errors_on(:weekend_hours_available).size).to eq 0
		end
	end
	
	context "pricing" do
		it "stores a description of pricing" do
			@profile.pricing = "$1/minute\n$40/15 minutes\n$120/hour"
			expect(@profile.errors_on(:pricing).size).to eq 0
		end
		
		it "has checkable options" do
			@profile.free_initial_consult = true
			@profile.sliding_scale_available = true
			@profile.financial_aid_available = true
			expect(@profile.errors_on(:free_initial_consult).size).to eq 0
			expect(@profile.errors_on(:sliding_scale_available).size).to eq 0
			expect(@profile.errors_on(:financial_aid_available).size).to eq 0
		end
	end
	
	context "locations" do
		it "has multiple locations" do
			@profile.locations.build(city: 'Albuquerque', region: 'NM')
			expect(@profile.errors_on(:locations).size).to eq 0
			expect(@profile.locations.first.errors_on(:city).size).to eq 0
			expect(@profile.locations.first.errors_on(:region).size).to eq 0
			@profile.locations.build(city: 'Manteca', region: 'CA')
			expect(@profile.errors_on(:locations).size).to eq 0
			expect(@profile.locations.last.errors_on(:city).size).to eq 0
			expect(@profile.locations.last.errors_on(:region).size).to eq 0
		end
		
		it "should update the locations count cache even when the location has been created first" do
			profile = FactoryGirl.create :profile
			profile.locations << FactoryGirl.create(:location)
			profile.reload
			# The count method on the association always does a database query,
			# so it's a reliable count of the associated location records.
			expect(profile.locations_count).to eq profile.locations.count
		end
		
		it "should have a list of displayable locations" do
			profile = FactoryGirl.build :profile
			profile.locations = []
			profile.locations.build(phone: '1-505-555-1001')
			profile.locations.build(city: 'Albuquerque', region: 'NM')
			expect(profile.displayable_sorted_locations.count).to eq 1
		end
	end
	
	context "reviews" do
		it "has multiple reviews" do
			@profile.reviews.build(body: 'This provider is fantastic!', reviewer_username: 'reviewer1234')
			expect(@profile.errors_on(:reviews).size).to eq 0
			expect(@profile.reviews.first.errors_on(:body).size).to eq 0
			@profile.reviews.build(body: 'This provider is adequate.', reviewer_username: 'reviewer1234')
			expect(@profile.errors_on(:reviews).size).to eq 0
			expect(@profile.reviews.last.errors_on(:body).size).to eq 0
		end
		
		it "should update the reviews count cache even when the review has been created first" do
			profile = FactoryGirl.create :profile
			profile.reviews << FactoryGirl.create(:review, reviewer_username: 'reviewer1234')
			profile.reload
			# The count method on the association always does a database query,
			# so it's a reliable count of the associated review records.
			expect(profile.reviews_count).to eq profile.reviews.count
		end
	end
	
	context "search" do
		context "matching criteria" do
			before(:example) do
				@profile = FactoryGirl.create(:published_profile, headline: 'Swedish dramatic soprano')
				Profile.reindex
				Sunspot.commit
			end
		
			it "does not require an exact match of query terms when searching profiles" do
				expect(Profile.fuzzy_search('famous Swedish sopranos').results.include?(@profile)).to be_truthy
			end
		
			it "requires at least two query terms to match out of three" do
				expect(Profile.fuzzy_search('famous Swedish tenors').results.include?(@profile)).to be_falsey
			end
		end
		
		context "ordering and restricting" do
			before(:example) do
				@summary_1 = 'Swedish dramatic soprano'
				@summary_2 = 'Italian dramatic soprano'
				@profile_1 = FactoryGirl.create(:published_profile, headline: @summary_1)
				@profile_2 = FactoryGirl.create(:published_profile, headline: @summary_2)
			end
			
			it "orders by relevance" do
				Profile.reindex
				Sunspot.commit
				results = Profile.fuzzy_search(@summary_1).results
				expect(results.size).to eq 2
				expect(results.first).to eq @profile_1
				expect(results.second).to eq @profile_2
			end
		
			context "geographic", geocoding_api: true, internet: true do
				before(:example) do
					@location_1 = @profile_1.locations.build({address1: '1398 Haight St', city: 'San Francisco', region: 'CA', postal_code: '94117'})
					@location_1.save
					@geocode_1 = {latitude: @location_1.latitude, longitude: @location_1.longitude}
					@location_2 = @profile_2.locations.build({address1: '1933 Davis Street', city: 'San Leandro', region: 'CA', postal_code: '94577'})
					@location_2.save
					@geocode_2 = {latitude: @location_2.latitude, longitude: @location_2.longitude}
					Profile.reindex
					Sunspot.commit
				end
				
				it "orders results by distance from a given latitude and longitude" do
					# Order wrt @geocode_2, so expect @profile_2 first.
					results = Profile.fuzzy_search(@summary_1, order_by_distance: @geocode_2).results
					expect(results.size).to eq 2
					expect(results.first).to eq @profile_2
					expect(results.second).to eq @profile_1
				end
				
				it "orders results by distance from a postal code" do
					# Order wrt @location_2.postal_code, so expect @profile_2 first.
					location = Location.new(postal_code: @location_2.postal_code)
					results = Profile.fuzzy_search(@summary_1, location: location).results
					expect(results.size).to eq 2
					expect(results.first).to eq @profile_2
					expect(results.second).to eq @profile_1
				end
				
				it "orders results by distance from a city" do
					# Order wrt @location_2 city and state, so expect @profile_2 first.
					location = Location.new(city: @location_2.city, region: @location_2.region)
					results = Profile.fuzzy_search(@summary_1, location: location).results
					expect(results.size).to eq 2
					expect(results.first).to eq @profile_2
					expect(results.second).to eq @profile_1
				end
				
				it "excludes results outside of a given radius" do
					# Assuming @geocode_1 and @geocode_2 are more than 0.5 km apart, we should only see one.
					results = Profile.fuzzy_search(@summary_1, within_radius: @geocode_1.merge(radius_km: 0.5)).results
					expect(results.size).to eq 1
					expect(results.first).to eq @profile_1
				end
				
				it "includes results within a given radius" do
					# Assuming @geocode_1 and @geocode_2 are less than 100 km apart, we should see both.
					results = Profile.fuzzy_search(@summary_1, within_radius: @geocode_1.merge(radius_km: 100)).results
					expect(results.size).to eq 2
				end
				
				context "using address option" do
					it "orders results by distance from a postal code" do
						# Order wrt @location_2.postal_code, so expect @profile_2 first.
						results = Profile.fuzzy_search(@summary_1, address: @location_2.postal_code).results
						expect(results.size).to eq 2
						expect(results.first).to eq @profile_2
						expect(results.second).to eq @profile_1
					end
				
					it "orders results by distance from a city" do
						# Order wrt @location_2 city and state, so expect @profile_2 first.
						results = Profile.fuzzy_search(@summary_1, address: "#{@location_2.city}, #{@location_2.region}").results
						expect(results.size).to eq 2
						expect(results.first).to eq @profile_2
						expect(results.second).to eq @profile_1
					end
				
					it "orders results by distance from a city with postal code" do
						# Order wrt @location_2 city, state, and postal code, so expect @profile_2 first.
						results = Profile.fuzzy_search(@summary_1, address: "#{@location_2.city}, #{@location_2.region} #{@location_2.postal_code}").results
						expect(results.size).to eq 2
						expect(results.first).to eq @profile_2
						expect(results.second).to eq @profile_1
					end
				end
			end
		end
	
		context "paginated" do
			before(:example) do
				FactoryGirl.create_list(:published_profile, 10, company_name: 'Moonlight Brewery')
				Profile.reindex
				Sunspot.commit
			end
		
			it "should return 4 results for the first page" do
				expect(Profile.fuzzy_search('moonlight', per_page: '4').results.size).to eq 4
			end
		
			it "should return 2 results for the third page" do
				expect(Profile.fuzzy_search('moonlight', per_page: '4', page: 3).results.size).to eq 2
			end
		end
		
		context "searching by service" do
			let(:service) { FactoryGirl.create :service, name: 'Brew Master' }
			let(:profile_with_service) { FactoryGirl.create :published_profile, services: [service] }
			let(:profile_with_name) { FactoryGirl.create :published_profile, headline: service.name }
		
			before(:example) do
				profile_with_name and profile_with_service
				Profile.reindex
				Sunspot.commit
			end
		
			it "should list first the profiles with the service assigned to them" do
				search = Profile.search_by_service service
				expect(search.results.size).to eq 2
				expect(search.results.first).to eq profile_with_service
				expect(search.results.second).to eq profile_with_name
			end
		
			it "should ONLY find profiles with the service assigned to them" do
				search = Profile.fuzzy_search service.name, service_id: service.id
				expect(search.results.size).to eq 1
				expect(search.results.first).to eq profile_with_service
			end
		end
		
		context "null search results" do
			before(:example) do
				FactoryGirl.create :published_profile, first_name: 'Maria', last_name: 'Callas'
				FactoryGirl.create :published_profile, first_name: 'Cesare', last_name: 'Valletti'
			end
			
			it "should return no results if no query is supplied to a fuzzy search" do
				expect(Profile.fuzzy_search('').results.size).to eq 0
			end
		end
	end
	
	context "character limits on string and text attributes" do
		it "limits the number of input characters for attributes stored as string or text records" do
			[:first_name, :last_name, :middle_name, :credentials, :company_name, :url, :headline,
				:certifications, :languages, :lead_generator, :photo_source_url, :ages_stages_note, :year_started,
				:education, :insurance_accepted, :pricing, :resources, :summary, :service_area,
				:hours, :admin_notes, :availability_service_area_note].each do |attr|
				s = 'a' * Profile::MAX_LENGTHS[attr]
				@profile.send "#{attr}=", s
				expect(@profile.errors_on(attr).size).to eq 0
				@profile.send "#{attr}=", (s + 'a')
				expect(@profile.error_on(attr).size).to eq 1
			end
		end
	end
	
	context "invite provider to claim their profile" do
		let(:recipient) { 'nicola@filacuridi.it' }
		let(:subject) { 'Claim your profile' }
		let(:body) { 'We are inviting you to claim your profile.' }
		let(:delivery_token) { '895d1d74-1951-11e4-83cc-00264afffe0a' }
		
		before(:example) do
			@profile.invitation_email = recipient
		end
		
		context "when profile is NOT saved before invitation is attempted" do
			it "does not send invitation email" do
				message = double('message')
				allow(ProfileMailer).to receive(:invite).and_return(message)
				expect(ProfileMailer).not_to receive(:invite)
				expect(message).not_to receive(:deliver)
				@profile.invite subject, body
			end
		end
		
		context "when profile is saved before invitation is attempted" do
			before(:example) do
				@profile.invitation_tracking_category = 'profile_claim'
				@profile.save
			end
		
			it "sends invitation email" do
				message = double('message')
				allow(@profile).to receive(:generate_token).and_return(delivery_token)
				expect(ProfileMailer).to receive(:invite).with(recipient, subject, body, @profile, delivery_token, false).and_return(message)
				expect(message).to receive(:deliver)
				@profile.invite subject, body
			end
			
			context "invitation attributes are properly set" do
				before(:example) do
					@profile.invite subject, body
					expect(@profile.errors.size).to eq 0
				end
				
				it "sets invitation token" do
					expect(@profile.invitation_token).to be_present
				end
				
				it "tracks invitation recipient" do
					expect(@profile.email_deliveries.where(recipient: recipient, email_type: 'invitation').last).to be_present
				end
			
				it "tracks invitation delivery time" do
					expect(delivery = @profile.email_deliveries.where(recipient: recipient, email_type: 'invitation').last).to be_present
					expect(delivery.created_at.to_f).to be_within(600).of(Time.zone.now.to_f) # be generous: within 10 minutes
				end
			
				it "has a tracking category" do
					expect(delivery = @profile.email_deliveries.where(recipient: recipient, email_type: 'invitation').last).to be_present
					expect(delivery.tracking_category).to eq @profile.invitation_tracking_category
				end
			end
		end
		
		context "when the profile has already been claimed" do
			it "should not send an invitation email" do
				@profile.user = FactoryGirl.create(:expert_user)
				@profile.save
				message = double('message')
				allow(ProfileMailer).to receive(:invite).and_return(message)
				expect(ProfileMailer).not_to receive(:invite)
				expect(message).not_to receive(:deliver)
				@profile.invite subject, body
			end
		end
	end
	
	it "has a scope that returns all profiles with admin notes" do
		admin_notes = 'Contact this provider'
		@profile.admin_notes = admin_notes
		@profile.save
		expect(Profile.with_admin_notes.first.admin_notes).to eq admin_notes
	end
	
	context "ratings" do
		let(:profile_to_rate) { FactoryGirl.create :published_profile }
		let(:zeus) { FactoryGirl.create :parent, email: 'zeus@example.com', username: 'zeus' }
		let(:hera) { FactoryGirl.create :parent, email: 'hera@example.com', username: 'hera' }
		
		before(:example) do
			profile = profile_to_rate.reload
			profile.ratings.each &:destroy
			profile.rate 2, zeus
			profile.rate 3, hera
		end
		
		it "maintains an average rating score" do
			expect(profile_to_rate.reload.rating_average_score).to be_within(0.01).of(2.5)
		end
		
		it "can rerate a review" do
			profile_to_rate.reload.rate 4, zeus
			expect(profile_to_rate.reload.rating_average_score).to be_within(0.01).of(3.5)
		end
		
		it "can remove a rating" do
			profile_to_rate.reload.rate nil, zeus
			expect(profile_to_rate.reload.rating_average_score).to be_within(0.01).of(3)
		end
		
		it "should update the ratings count cache" do
			profile_to_rate.reload
			# The count method on the association always does a database query,
			# so it's a reliable count of the associated rating records.
			expect(profile_to_rate.ratings_count).to eq profile_to_rate.ratings.count
		end
	end
	
	context "profile ownership" do
		before (:each) do
			@me = FactoryGirl.create(:expert_user, email: 'me@example.com')
		end
		
		it "is not my profile" do
			expect(@profile).not_to be_owned_by(@me)
		end
		
		it "is my profile" do
			@me.profile = @profile
			expect(@profile).to be_owned_by(@me)
		end
	end
	
	context "stages and ages" do
		let(:profile) { FactoryGirl.build :profile }
		let(:first_age_range) { FactoryGirl.create :age_range, name: 'Preconception', sort_index: 1 }
		let(:second_age_range) { FactoryGirl.create :age_range, name: 'Pregnancy/Childbirth', sort_index: 2 }
		let(:retired_age_range) { FactoryGirl.create :retired_age_range, name: '11-14' }
		
		it "accepts clients from first two age ranges" do
			profile.age_ranges = [first_age_range, second_age_range]
			expect(profile.age_ranges.include?(first_age_range)).to be_truthy
			expect(profile.age_ranges.include?(second_age_range)).to be_truthy
		end
		
		it "does not accept clients from first age range" do
			profile.age_ranges = [second_age_range]
			expect(profile.age_ranges.include?(first_age_range)).to be_falsey
		end
		
		it "exposes its sorted age range names" do
			profile.age_ranges = [second_age_range, first_age_range]
			expect(profile.age_ranges.size).to eq 2
			names = profile.age_range_names
			expect(names.first).to eq first_age_range.name
			expect(names.second).to eq second_age_range.name
		end
		
		it "displays its age ranges" do
			profile.age_ranges = [first_age_range, second_age_range]
			expect(profile.display_age_ranges.include?(first_age_range.name)).to be_truthy
			expect(profile.display_age_ranges.include?(second_age_range.name)).to be_truthy
		end
		
		it "does not expose retired age ranges" do
			profile.age_ranges = [first_age_range, retired_age_range]
			expect(profile.age_ranges.size).to eq 1
			expect(profile.age_ranges.include?(retired_age_range)).to be_falsey
		end
		
		it "has a comment field" do
			profile.ages_stages_note = note = 'Lorem ipsum'
			expect(profile.ages_stages_note).to eq note
		end
	end
	
	context "year started" do
		it "accepts a four digit year" do
			@profile.year_started = '1998'
			expect(@profile.errors_on(:year_started).size).to eq 0
		end
		
		it "accepts alphanumeric text" do
			@profile.year_started = 'Institute established: 1953; Day School established: 1973'
			expect(@profile.errors_on(:year_started).size).to eq 0
		end
	end
	
	context "email addresses" do
		it "accepts a valid email address" do
			[:email, :invitation_email].each do |attr|
				@profile.send "#{attr}=", 'a@b.com'
				expect(@profile.errors_on(attr).size).to eq 0
			end
		end
		
		it "rejects an invalid email address" do
			[:email, :invitation_email].each do |attr|
				@profile.send "#{attr}=", 'a@b.'
				expect(@profile.error_on(attr).size).to eq 1
			end
		end
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		email = 'a@b.com'
		@profile.email = " #{email} "
		expect(@profile.errors_on(:email).size).to eq 0
		expect(@profile.email).to eq email
	end
	
	context "claimable profile" do
		it "finds a claimable profile by its claim token" do
			profile = FactoryGirl.create :claimable_profile
			expect(Profile.find_claimable(profile.invitation_token)).to eq profile
		end
		
		it "does not return a profile with no claim token" do
			profile = FactoryGirl.create :unclaimable_profile
			expect(Profile.find_claimable(profile.invitation_token)).to be_nil
		end
		
		it "does not return a profile that has been claimed" do
			profile = FactoryGirl.create :claimed_profile
			expect(Profile.find_claimable(profile.invitation_token)).to be_nil
		end
	end

	context "AFTER save", mailchimp: true do
		it "should notify MailChimp, if first name changed" do
			list_id = mailchimp_list_ids[:provider_newsletters]
			@profile.user = FactoryGirl.create(:expert_user, provider_newsletters: true)
			@profile.save
			@profile.reload
			@profile.first_name = "Bob"
			merge_vars = { FNAME: @profile.first_name, LNAME: @profile.last_name }
			opts = {
				email: { email: @profile.user.email, leid: @profile.user.provider_newsletters_leid },
				id: list_id,
				merge_vars: merge_vars,
				double_optin: false,
				update_existing: true
			}
			# We can do the following because we are mocking the lists API.
			expect(Gibbon::API.new.lists).to receive(:subscribe).with(opts).once
			@profile.save
		end
	end
end
