require 'spec_helper'

describe Profile do
	before(:each) do
		@profile = Profile.new
		@profile.first_name = 'Joe'
		@profile.last_name = 'Black'
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
		before(:each) do
			@categories = ['board-certified behavior analyst', 'child/clinical psychologist']
			@profile.categories = @categories
		end
		
		it "stores multiple categories" do
			@profile.save.should be_true
			@profile.categories.should == @categories
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
		before(:each) do
			@specialties = ['behavior', 'choosing a school (pre-K to 12)']
			@profile.specialties = @specialties
		end
		
		it "stores multiple specialties" do
			@profile.save.should be_true
			@profile.specialties.should == @specialties
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
