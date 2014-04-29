require 'spec_helper'

describe Profile do
	before(:each) do
		@profile_data ||= {
			first_name: 'Joe', last_name: 'Black',
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
			@profile.should have(:no).errors_on(:first_name)
			@profile.should have(:no).errors_on(:last_name)
		end
		
		it "is happy if first and last name are NOT set" do
			@profile.first_name = ''
			@profile.last_name = ''
			@profile.should have(:no).errors_on(:first_name)
			@profile.should have(:no).errors_on(:last_name)
		end
	end
	
	context "display name" do
		it "contains first, middle, and last name as well as credentials" do
			@profile.middle_name = 'X'
			@profile.credentials = 'BA, MA'
			@profile.display_name.should =~ /#{@profile.first_name}.*#{@profile.middle_name}.*#{@profile.last_name}.*#{@profile.credentials}/
		end
	end
	
	context "display name or company" do
		it "returns display name if first name is present" do
			@profile.last_name = ''
			@profile.display_name_or_company.should == @profile.display_name
		end
		
		it "returns display name if last name is present" do
			@profile.first_name = ''
			@profile.display_name_or_company.should == @profile.display_name
		end
		
		it "returns company name if neither first name nor last name are present" do
			@profile.first_name = ''
			@profile.last_name = ''
			@profile.display_name_or_company.should == @profile.company_name
		end
	end
	
	context "categories" do
		it "stores a category" do
			@profile.save.should be_true
			Profile.find_by_last_name(@profile_data[:last_name]).categories.should == @profile_data[:categories]
		end
		
		it "does not require a category if not publishing" do
			@profile.is_published = false
			@profile.categories = []
			@profile.should have(:no).errors_on(:categories)
		end
		
		it "allows more than one category" do
			@profile.categories = @profile_data[:categories]
			@profile.categories << FactoryGirl.create(:category, name: 'MISC.')
			@profile.should have(:no).errors_on(:categories)
		end
	end
	
	context "services" do
		it "stores multiple services" do
			@profile.save.should be_true
			stored_services = Profile.find_by_last_name(@profile_data[:last_name]).services
			@profile_data[:services].each do |svc|
				stored_services.include?(svc).should be_true
			end
		end
		
		context "custom services" do
			it "merges custom services" do
				custom = [@profile_data[:services].first.name, 'story teller']
				@profile.custom_service_names = custom
				@profile.save.should == true
				profile = Profile.find_by_last_name(@profile_data[:last_name])
				profile.should have_exactly(@profile_data[:services].size + 1).services
				profile.services.collect(&:name).include?(custom.last).should be_true
			end
			
			it "limits length of name" do
				name = 'a' * Profile::MAX_LENGTHS[:custom_service_names]
				@profile.custom_service_names = [name]
				@profile.should have(:no).error_on(:custom_service_names)
				@profile.custom_service_names = [name + 'a']
				@profile.should have(1).error_on(:custom_service_names)
			end
			
			it "filters out blanks and strips" do
				name = 'Theremin Teacher'
				@profile.custom_service_names = [nil, '', ' ', " #{name} "]
				@profile.should have(:no).errors_on(:custom_service_names)
				@profile.should have(1).custom_service_name
				@profile.custom_service_names.first.should == name
			end
		end
	end
	
	context "specialties" do
		it "stores multiple specialties" do
			@profile.save.should be_true
			stored_specialties = Profile.find_by_last_name(@profile_data[:last_name]).specialties
			@profile_data[:specialties].each do |spc|
				stored_specialties.include?(spc).should be_true
			end
		end
		
		it "does not require a specialty" do
			@profile.specialties = []
			@profile.should have(:no).errors_on(:specialties)
		end
		
		it "has a simple array of specialty IDs and names" do
			ids_names = @profile.specialty_ids_names
			specialties_data = @profile_data[:specialties]
			ids_names.each_index do |i|
				specialties_data[i].id.should == ids_names[i][:id]
				specialties_data[i].name.should == ids_names[i][:name]
			end
		end
		
		context "custom specialties" do
			it "merges custom specialties" do
				custom = [@profile_data[:specialties].first.name, 'parenting support']
				@profile.custom_specialty_names = custom
				@profile.save.should == true
				profile = Profile.find_by_last_name(@profile_data[:last_name])
				profile.should have_exactly(@profile_data[:specialties].size + 1).specialties
				profile.specialties.collect(&:name).include?(custom.last).should be_true
			end
			
			it "limits length of name" do
				name = 'a' * Profile::MAX_LENGTHS[:custom_specialty_names]
				@profile.custom_specialty_names = [name]
				@profile.should have(:no).error_on(:custom_specialty_names)
				@profile.custom_specialty_names = [name + 'a']
				@profile.should have(1).error_on(:custom_specialty_names)
			end
			
			it "filters out blanks and strips" do
				name = 'theremin instruction'
				@profile.custom_specialty_names = [nil, '', ' ', " #{name} "]
				@profile.should have(:no).errors_on(:custom_specialty_names)
				@profile.should have(1).custom_specialty_name
				@profile.custom_specialty_names.first.should == name
			end
		end
		
		it "stores a text description of specialties" do
			@profile.specialties_description = 'methods of parenting, parent/child communication, parenting through separation and divorce'
			@profile.should have(:no).errors_on(:specialties_description)
		end
	end
	
	context "consultations" do
		it "stores contact options" do
			@profile.consult_by_email = true
			@profile.consult_by_phone = true
			@profile.consult_by_video = false
			@profile.visit_home = true
			@profile.visit_school = false
			@profile.should have(:no).errors_on(:consult_by_email)
			@profile.should have(:no).errors_on(:consult_by_phone)
			@profile.should have(:no).errors_on(:consult_by_video)
			@profile.should have(:no).errors_on(:visit_home)
			@profile.should have(:no).errors_on(:visit_school)
		end
		
		it "stores consultation option for providers that offer most or all of their services remotely" do
			@profile.consult_remotely = true
			@profile.should have(:no).errors_on(:consult_remotely)
		end
	end
	
	context "hours" do
		it "stores a description of hours" do
			@profile.hours = "9:00 AM to 5:00 PM, MWF\n11:00 AM to 3:00 PM, TuTh"
			@profile.should have(:no).errors_on(:hours)
		end
		
		it "has checkable options" do
			@profile.evening_hours_available = true
			@profile.weekend_hours_available = true
			@profile.should have(:no).errors_on(:evening_hours_available)
			@profile.should have(:no).errors_on(:weekend_hours_available)
		end
	end
	
	context "pricing" do
		it "stores a description of pricing" do
			@profile.pricing = "$1/minute\n$40/15 minutes\n$120/hour"
			@profile.should have(:no).errors_on(:pricing)
		end
		
		it "has checkable options" do
			@profile.free_initial_consult = true
			@profile.sliding_scale_available = true
			@profile.financial_aid_available = true
			@profile.should have(:no).errors_on(:free_initial_consult)
			@profile.should have(:no).errors_on(:sliding_scale_available)
			@profile.should have(:no).errors_on(:financial_aid_available)
		end
	end
	
	context "locations" do
		it "has multiple locations" do
			@profile.locations.build(city: 'Albuquerque', region: 'NM')
			@profile.should have(:no).errors_on(:locations)
			@profile.locations.first.should have(:no).errors_on(:city)
			@profile.locations.first.should have(:no).errors_on(:region)
			@profile.locations.build(city: 'Manteca', region: 'CA')
			@profile.should have(:no).errors_on(:locations)
			@profile.locations.last.should have(:no).errors_on(:city)
			@profile.locations.last.should have(:no).errors_on(:region)
		end
		
		it "should update the locations count cache even when the location has been created first" do
			profile = FactoryGirl.create :profile
			profile.locations << FactoryGirl.create(:location)
			profile.reload
			# The count method on the association always does a database query,
			# so it's a reliable count of the associated location records.
			profile.locations_count.should == profile.locations.count
		end
	end
	
	context "reviews" do
		it "has multiple reviews" do
			@profile.reviews.build(body: 'This provider is fantastic!')
			@profile.should have(:no).errors_on(:reviews)
			@profile.reviews.first.should have(:no).errors_on(:body)
			@profile.reviews.build(body: 'This provider is adequate.')
			@profile.should have(:no).errors_on(:reviews)
			@profile.reviews.last.should have(:no).errors_on(:body)
		end
		
		it "should update the reviews count cache even when the review has been created first" do
			profile = FactoryGirl.create :profile
			profile.reviews << FactoryGirl.create(:review)
			profile.reload
			# The count method on the association always does a database query,
			# so it's a reliable count of the associated review records.
			profile.reviews_count.should == profile.reviews.count
		end
	end
	
	context "search" do
		context "matching crieria" do
			before(:each) do
				@profile = FactoryGirl.create(:published_profile, summary: 'Swedish dramatic soprano')
				Profile.reindex
				Sunspot.commit
			end
		
			it "does not require an exact match of query terms when searching profiles" do
				Profile.fuzzy_search('famous Swedish sopranos').results.include?(@profile).should be_true
			end
		
			it "requires at least two query terms to match out of three" do
				Profile.fuzzy_search('famous Swedish tenors').results.include?(@profile).should be_false
			end
		end
		
		context "ordering and restricting" do
			before(:each) do
				@summary_1 = 'Swedish dramatic soprano'
				@summary_2 = 'Italian dramatic soprano'
				@profile_1 = FactoryGirl.create(:published_profile, summary: @summary_1)
				@profile_2 = FactoryGirl.create(:published_profile, summary: @summary_2)
			end
			
			it "orders by relevance" do
				Profile.reindex
				Sunspot.commit
				results = Profile.fuzzy_search(@summary_1).results
				results.should have(2).things
				results.first.should == @profile_1
				results.second.should == @profile_2
			end
		
			context "geographic", geocoding_api: true, internet: true do
				before(:each) do
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
					results.should have(2).things
					results.first.should == @profile_2
					results.second.should == @profile_1
				end
				
				it "orders results by distance from a postal code" do
					# Order wrt @location_2.postal_code, so expect @profile_2 first.
					location = Location.new(postal_code: @location_2.postal_code)
					results = Profile.fuzzy_search(@summary_1, location: location).results
					results.should have(2).things
					results.first.should == @profile_2
					results.second.should == @profile_1
				end
				
				it "orders results by distance from a city" do
					# Order wrt @location_2 city and state, so expect @profile_2 first.
					location = Location.new(city: @location_2.city, region: @location_2.region)
					results = Profile.fuzzy_search(@summary_1, location: location).results
					results.should have(2).things
					results.first.should == @profile_2
					results.second.should == @profile_1
				end
				
				it "excludes results outside of a given radius" do
					# Assuming @geocode_1 and @geocode_2 are more than 0.5 km apart, we should only see one.
					results = Profile.fuzzy_search(@summary_1, within_radius: @geocode_1.merge(radius_km: 0.5)).results
					results.should have(1).thing
					results.first.should == @profile_1
				end
				
				it "includes results within a given radius" do
					# Assuming @geocode_1 and @geocode_2 are less than 100 km apart, we should see both.
					results = Profile.fuzzy_search(@summary_1, within_radius: @geocode_1.merge(radius_km: 100)).results
					results.should have(2).things
				end
				
				context "using address option" do
					it "orders results by distance from a postal code" do
						# Order wrt @location_2.postal_code, so expect @profile_2 first.
						results = Profile.fuzzy_search(@summary_1, address: @location_2.postal_code).results
						results.should have(2).things
						results.first.should == @profile_2
						results.second.should == @profile_1
					end
				
					it "orders results by distance from a city" do
						# Order wrt @location_2 city and state, so expect @profile_2 first.
						results = Profile.fuzzy_search(@summary_1, address: "#{@location_2.city}, #{@location_2.region}").results
						results.should have(2).things
						results.first.should == @profile_2
						results.second.should == @profile_1
					end
				
					it "orders results by distance from a city with postal code" do
						# Order wrt @location_2 city, state, and postal code, so expect @profile_2 first.
						results = Profile.fuzzy_search(@summary_1, address: "#{@location_2.city}, #{@location_2.region} #{@location_2.postal_code}").results
						results.should have(2).things
						results.first.should == @profile_2
						results.second.should == @profile_1
					end
				end
			end
		end
	
		context "paginated" do
			before(:each) do
				FactoryGirl.create_list(:published_profile, 10, company_name: 'Moonlight Brewery')
				Profile.reindex
				Sunspot.commit
			end
		
			it "should return 4 results for the first page" do
				Profile.fuzzy_search('moonlight', per_page: '4').should have(4).results
			end
		
			it "should return 2 results for the third page" do
				Profile.fuzzy_search('moonlight', per_page: '4', page: 3).should have(2).results
			end
		end
		
		context "searching by service" do
			let(:service) { FactoryGirl.create :service, name: 'Brew Master' }
			let(:profile_with_service) { FactoryGirl.create :published_profile, services: [service] }
			let(:profile_with_name) { FactoryGirl.create :published_profile, headline: service.name }
		
			before(:each) do
				profile_with_name and profile_with_service
				Profile.reindex
				Sunspot.commit
			end
		
			it "should list first the profiles with the service assigned to them" do
				search = Profile.search_by_service service
				search.should have(2).results
				search.results.first.should == profile_with_service
				search.results.second.should == profile_with_name
			end
		
			it "should ONLY find profiles with the service assigned to them" do
				search = Profile.fuzzy_search service.name, service_id: service.id
				search.should have(1).result
				search.results.first.should == profile_with_service
			end
		end
		
		context "null search results" do
			before(:each) do
				FactoryGirl.create :published_profile, first_name: 'Maria', last_name: 'Callas'
				FactoryGirl.create :published_profile, first_name: 'Cesare', last_name: 'Valletti'
			end
			
			it "should return no results if no query is supplied to a fuzzy search" do
				Profile.fuzzy_search('').should have(:no).results
			end
		end
	end
	
	context "character limits on string and text attributes" do
		it "limits the number of input characters for attributes stored as string or text records" do
			[:first_name, :last_name, :middle_name, :credentials, :company_name, :url, :headline,
				:certifications, :languages, :lead_generator, :photo_source_url, :ages_stages_note, :year_started,
				:education, :insurance_accepted, :pricing, :summary, :service_area,
				:hours, :admin_notes, :availability_service_area_note].each do |attr|
				s = 'a' * Profile::MAX_LENGTHS[attr]
				@profile.send "#{attr}=", s
				@profile.should have(:no).errors_on(attr)
				@profile.send "#{attr}=", (s + 'a')
				@profile.should have(1).error_on(attr)
			end
		end
	end
	
	context "invite provider to claim their profile" do
		let(:recipient) { 'nicola@filacuridi.it' }
		let(:subject) { 'Claim your profile' }
		let(:body) { 'We are inviting you to claim your profile.' }
		
		before(:each) do
			@profile.invitation_email = recipient
		end
		
		context "when profile is NOT saved before invitation is attempted" do
			it "does not send invitation email" do
				message = mock('message')
				ProfileMailer.stub(:invite).and_return(message)
				ProfileMailer.should_not_receive(:invite).with(recipient, subject, body, @profile)
				message.should_not_receive(:deliver)
				@profile.invite recipient, subject, body
			end
		end
		
		context "when profile is saved before invitation is attempted" do
			before(:each) do
				@profile.save
			end
		
			it "sends invitation email" do
				message = mock('message')
				ProfileMailer.should_receive(:invite).with(recipient, subject, body, @profile).and_return(message)
				message.should_receive(:deliver)
				@profile.invite recipient, subject, body
			end
			
			context "invitation attributes are properly set" do
				before(:each) do
					@profile.invite recipient, subject, body
					@profile.should have(:no).errors
				end
				
				it "sets invitation token" do
					@profile.invitation_token.should be_present
				end
			
				it "sets invitation delivery time" do
					@profile.invitation_sent_at.should be_present
					@profile.invitation_sent_at.to_f.should be_within(600).of(Time.zone.now.to_f) # be generous: within 10 minutes
				end
			end
		end
		
		context "when the profile has already been claimed" do
			it "should not send an invitation email" do
				@profile.user = FactoryGirl.create(:expert_user)
				@profile.save
				message = mock('message')
				ProfileMailer.stub(:invite).and_return(message)
				ProfileMailer.should_not_receive(:invite).with(recipient, subject, body, @profile)
				message.should_not_receive(:deliver)
				@profile.invite recipient, subject, body
			end
		end
	end
	
	it "has a scope that returns all profiles with admin notes" do
		admin_notes = 'Contact this provider'
		@profile.admin_notes = admin_notes
		@profile.save
		Profile.with_admin_notes.first.admin_notes.should == admin_notes
	end
	
	context "ratings" do
		let(:profile_to_rate) { FactoryGirl.create :published_profile }
		let(:zeus) { FactoryGirl.create :parent, email: 'zeus@example.com', username: 'zeus' }
		let(:hera) { FactoryGirl.create :parent, email: 'hera@example.com', username: 'hera' }
		
		before(:each) do
			profile = profile_to_rate.reload
			profile.ratings.each &:destroy
			profile.rate 2, zeus
			profile.rate 3, hera
		end
		
		it "maintains an average rating score" do
			profile_to_rate.reload.rating_average_score.should be_within(0.01).of(2.5)
		end
		
		it "can rerate a review" do
			profile_to_rate.reload.rate 4, zeus
			profile_to_rate.reload.rating_average_score.should be_within(0.01).of(3.5)
		end
		
		it "can remove a rating" do
			profile_to_rate.reload.rate nil, zeus
			profile_to_rate.reload.rating_average_score.should be_within(0.01).of(3)
		end
		
		it "should update the ratings count cache" do
			profile_to_rate.reload
			# The count method on the association always does a database query,
			# so it's a reliable count of the associated rating records.
			profile_to_rate.ratings_count.should == profile_to_rate.ratings.count
		end
	end
	
	context "profile ownership" do
		before (:each) do
			@me = FactoryGirl.create(:expert_user, email: 'me@example.com')
		end
		
		it "is not my profile" do
			@profile.should_not be_owned_by(@me)
		end
		
		it "is my profile" do
			@me.profile = @profile
			@profile.should be_owned_by(@me)
		end
	end
	
	context "stages and ages" do
		let(:profile) { FactoryGirl.build :profile }
		let(:first_age_range) { FactoryGirl.create :age_range, name: 'Preconception', sort_index: 1 }
		let(:second_age_range) { FactoryGirl.create :age_range, name: 'Pregnancy/Childbirth', sort_index: 2 }
		let(:retired_age_range) { FactoryGirl.create :retired_age_range, name: '11-14' }
		
		it "accepts clients from first two age ranges" do
			profile.age_ranges = [first_age_range, second_age_range]
			profile.age_ranges.include?(first_age_range).should be_true
			profile.age_ranges.include?(second_age_range).should be_true
		end
		
		it "does not accept clients from first age range" do
			profile.age_ranges = [second_age_range]
			profile.age_ranges.include?(first_age_range).should be_false
		end
		
		it "exposes its sorted age range names" do
			profile.age_ranges = [second_age_range, first_age_range]
			profile.should have(2).age_range_names
			(names = profile.age_range_names).first.should == first_age_range.name
			names.second.should == second_age_range.name
		end
		
		it "displays its age ranges" do
			profile.age_ranges = [first_age_range, second_age_range]
			profile.display_age_ranges.include?(first_age_range.name).should be_true
			profile.display_age_ranges.include?(second_age_range.name).should be_true
		end
		
		it "does not expose retired age ranges" do
			profile.age_ranges = [first_age_range, retired_age_range]
			profile.should have(1).age_range
			profile.age_ranges.include?(retired_age_range).should be_false
		end
		
		it "has a comment field" do
			profile.ages_stages_note = note = 'Lorem ipsum'
			profile.ages_stages_note.should == note
		end
	end
	
	context "year started" do
		it "accepts a four digit year" do
			@profile.year_started = '1998'
			@profile.should have(:no).errors_on(:year_started)
		end
		
		it "accepts alphanumeric text" do
			@profile.year_started = 'Institute established: 1953; Day School established: 1973'
			@profile.should have(:no).errors_on(:year_started)
		end
	end
	
	context "email addresses" do
		it "accepts a valid email address" do
			[:email, :invitation_email].each do |attr|
				@profile.send "#{attr}=", 'a@b.com'
				@profile.should have(:no).errors_on(attr)
			end
		end
		
		it "rejects an invalid email address" do
			[:email, :invitation_email].each do |attr|
				@profile.send "#{attr}=", 'a@b.'
				@profile.should have(1).error_on(attr)
			end
		end
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		email = 'a@b.com'
		@profile.email = " #{email} "
		@profile.should have(:no).errors_on(:email)
		@profile.email.should == email
	end
	
	context "claimable profile" do
		it "finds a claimable profile by its claim token" do
			profile = FactoryGirl.create :claimable_profile
			Profile.find_claimable(profile.invitation_token).should == profile
		end
		
		it "does not return a profile with no claim token" do
			profile = FactoryGirl.create :unclaimable_profile
			Profile.find_claimable(profile.invitation_token).should be_nil
		end
		
		it "does not return a profile that has been claimed" do
			profile = FactoryGirl.create :claimed_profile
			Profile.find_claimable(profile.invitation_token).should be_nil
		end
	end
end
