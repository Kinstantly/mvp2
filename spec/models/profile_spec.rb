require 'spec_helper'

describe Profile do
	before(:each) do
		@profile = Profile.new
		@profile.first_name = 'Joe'
		@profile.last_name = 'Black'
		@categories = ['board-certified behavior analyst', 'child/clinical psychologist']
		@profile.categories = @categories
		@specialties = ['behavior', 'choosing a school (pre-K to 12)']
		@profile.specialties = @specialties
	end
	
	context "name" do
		it "is happy if we set both first and last name" do
			@profile.should have(:no).errors_on(:first_name)
			@profile.should have(:no).errors_on(:last_name)
		end
		
		it "complains if first and last name are not set" do
			@profile.first_name = ''
			@profile.last_name = ''
			@profile.should have(1).errors_on(:first_name)
			@profile.should have(1).errors_on(:last_name)
		end
	end
	
	context "categories" do
		it "stores multiple categories" do
			@profile.save.should be_true
			@profile.categories.should == @categories
		end
		
		it "requires at least one category" do
			@profile.categories = []
			@profile.should have(1).errors_on(:categories)
		end
		
		context "custom categories" do
			before(:each) do
				@custom = [@categories.first, 'story teller']
				@profile.custom_category_names = @custom
			end
			
			it "merges custom categories" do
				@profile.save.should == true
				@profile.should have_exactly(@categories.size + 1).categories
				@profile.categories.include?(@custom.last).should be_true
			end
		end
	end
	
	context "specialties" do
		it "stores multiple specialties" do
			@profile.save.should be_true
			@profile.specialties.should == @specialties
		end
		
		it "requires at least one specialty" do
			@profile.specialties = []
			@profile.should have(1).errors_on(:specialties)
		end
		
		context "custom specialties" do
			before(:each) do
				@custom = [@specialties.first, 'parenting support']
				@profile.custom_specialty_names = @custom
			end
			
			it "merges custom specialties" do
				@profile.save.should == true
				@profile.should have_exactly(@specialties.size + 1).specialties
				@profile.specialties.include?(@custom.last).should be_true
			end
		end
	end
	
	context "consultations and visits" do
		it "stores consultation preferences" do
			@profile.consult_by_email = true
			@profile.consult_by_phone = true
			@profile.consult_by_video = false
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
	
	context "Profile configuration" do
		it "has predefined categories" do
			Profile.predefined_categories.length.should be > 0
			Profile.predefined_categories.include?('parenting coach/educator').should be_true
		end
		
		it "has predefined specialties" do
			Profile.predefined_specialties.length.should be > 0
			Profile.predefined_specialties.include?('behavior').should be_true
		end
		
		it "has specialties tied to category" do
			specialties = Profile.categories_specialties_map['parenting coach/educator']
			specialties.length.should be > 0
			specialties.include?('behavior').should be_true
		end
	end
end
