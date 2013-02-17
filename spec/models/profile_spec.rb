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
	
	context "publishing requirements" do
		before(:each) do
			@profile.is_published = true
		end
		
		it "will not be published if none of first name, last name, or company name are supplied" do
			@profile.first_name = @profile.last_name = @profile.company_name = ''
			@profile.categories = @profile_data[:categories]
			@profile.should have(1).errors_on(:first_name)
		end
		
		it "will not be published if a category is not set" do
			@profile.company_name = 'Figaro, Inc.'
			@profile.categories = []
			@profile.should have(1).errors_on(:category)
		end
		
		it "will not be published if only a last name is supplied" do
			@profile.first_name = ''
			@profile.last_name = 'di Almaviva'
			@profile.company_name = ''
			@profile.categories = @profile_data[:categories]
			@profile.should have(1).errors_on(:first_name)
		end
		
		it "will be published if both a full name and category are supplied" do
			@profile.first_name = 'Il Conte'
			@profile.last_name = 'di Almaviva'
			@profile.company_name = ''
			@profile.categories = @profile_data[:categories]
			@profile.should have(:no).errors_on(:first_name)
			@profile.should have(:no).errors_on(:category)
		end
		
		it "will be published if both a company name and category are supplied" do
			@profile.first_name = ''
			@profile.last_name = ''
			@profile.company_name = 'Figaro, Inc.'
			@profile.categories = @profile_data[:categories]
			@profile.should have(:no).errors_on(:first_name)
			@profile.should have(:no).errors_on(:category)
		end
		
		it "no problem if we are not trying to publish" do
			@profile.is_published = false
			@profile.first_name = @profile.last_name = @profile.company_name = ''
			@profile.categories = []
			@profile.should have(:no).errors_on(:first_name)
			@profile.should have(:no).errors_on(:category)
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
			Profile.find_by_last_name(@profile_data[:last_name]).services.should == @profile_data[:services]
		end
		
		context "custom services" do
			before(:each) do
				@custom = [@profile_data[:services].first.name, 'story teller']
				@profile.custom_service_names = @custom
			end
			
			it "merges custom services" do
				@profile.save.should == true
				profile = Profile.find_by_last_name(@profile_data[:last_name])
				profile.should have_exactly(@profile_data[:services].size + 1).services
				profile.services.collect(&:name).include?(@custom.last).should be_true
			end
		end
	end
	
	context "specialties" do
		it "stores multiple specialties" do
			@profile.save.should be_true
			Profile.find_by_last_name(@profile_data[:last_name]).specialties.should == @profile_data[:specialties]
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
			before(:each) do
				@custom = [@profile_data[:specialties].first.name, 'parenting support']
				@profile.custom_specialty_names = @custom
			end
			
			it "merges custom specialties" do
				@profile.save.should == true
				profile = Profile.find_by_last_name(@profile_data[:last_name])
				profile.should have_exactly(@profile_data[:specialties].size + 1).specialties
				profile.specialties.collect(&:name).include?(@custom.last).should be_true
			end
		end
		
		it "stores a text description of specialties" do
			@profile.specialties_description = 'methods of parenting, parent/child communication, parenting through separation and divorce'
			@profile.should have(:no).errors_on(:specialties_description)
		end
	end
	
	context "consultations and visits" do
		it "stores consultation preferences" do
			@profile.consult_in_person = true
			@profile.consult_by_email = true
			@profile.consult_by_phone = true
			@profile.consult_by_video = false
			@profile.should have(:no).errors_on(:consult_in_person)
			@profile.should have(:no).errors_on(:consult_by_email)
			@profile.should have(:no).errors_on(:consult_by_phone)
			@profile.should have(:no).errors_on(:consult_by_video)
		end
		
		it "stores visitation preferences" do
			@profile.visit_home = true
			@profile.visit_school = false
			@profile.should have(:no).errors_on(:visit_home)
			@profile.should have(:no).errors_on(:visit_school)
		end
	end
	
	context "rates" do
		it "stores a description of rates" do
			@profile.rates = "$1/minute\n$40/15 minutes\n$120/hour"
			@profile.should have(:no).errors_on(:rates)
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
	end
	
	context "search" do
		context "matching crieria" do
			before(:each) do
				@profile = FactoryGirl.create(:profile, summary: 'Swedish dramatic soprano', is_published: true)
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
				@profile_1 = FactoryGirl.create(:profile, summary: @summary_1, is_published: true)
				@profile_2 = FactoryGirl.create(:profile, summary: @summary_2, is_published: true)
			end
			
			it "orders by relevance" do
				Profile.reindex
				Sunspot.commit
				results = Profile.fuzzy_search(@summary_1).results
				results.should have(2).things
				results.first.should == @profile_1
				results.second.should == @profile_2
			end
		
			context "geographic" do
				before(:each) do
					@geocode_1 = {latitude: 37.7701468, longitude: -122.4451098}
					@geocode_2 = {latitude: 37.7633971, longitude: -122.4664416}
					# Location's latitude and longitude cannot be mass-assigned, so do it the hard way.
					@location_1 = @profile_1.locations.build
					@location_1.latitude = @geocode_1[:latitude]
					@location_1.longitude = @geocode_1[:longitude]
					@location_1.save
					@location_2 = @profile_2.locations.build
					@location_2.latitude = @geocode_2[:latitude]
					@location_2.longitude = @geocode_2[:longitude]
					@location_2.save
					Profile.reindex
					Sunspot.commit
				end
				
				it "orders results by distance from a location" do
					# Order wrt @geocode_2, so expect @profile_2 first.
					results = Profile.fuzzy_search(@summary_1, order_by_distance: @geocode_2).results
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
			end
		end
	end
	
	context "character limits on text attributes" do
		it "limits the number of input characters for attributes stored as text records" do
			s = 'a' * 1001
			[:availability, :awards, :education, :experience, :insurance_accepted, :rates, :summary, 
				:office_hours, :phone_hours, :video_hours].each do |attr|
				@profile.send "#{attr}=", s
				@profile.should have(1).error_on(attr)
			end
		end
	end
	
	context "invite provider to claim their profile" do
		before(:each) do
			@profile.invitation_email = 'nicola@filacuridi.it'
		end
		
		context "when profile is NOT saved before invitation is attempted" do
			it "does not send invitation email" do
				message = mock('message')
				ProfileMailer.stub(:invite).and_return(message)
				ProfileMailer.should_not_receive(:invite).with(@profile)
				message.should_not_receive(:deliver)
				@profile.invite
			end
		end
		
		context "when profile is saved before invitation is attempted" do
			before(:each) do
				@profile.save
			end
		
			it "sends invitation email" do
				message = mock('message')
				ProfileMailer.should_receive(:invite).with(@profile).and_return(message)
				message.should_receive(:deliver)
				@profile.invite
			end
			
			context "invitation attributes are properly set" do
				before(:each) do
					@profile.invite
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
				ProfileMailer.should_not_receive(:invite).with(@profile)
				message.should_not_receive(:deliver)
				@profile.invite
			end
		end
	end
end
