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
		
		it "requires a category" do
			@profile.categories = []
			@profile.should have(1).errors_on(:categories)
		end
		
		it "allows only one category" do
			@profile.categories = @profile_data[:categories]
			@profile.categories << FactoryGirl.create(:category, name: 'MISC.')
			@profile.should have(1).errors_on(:categories)
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
end
