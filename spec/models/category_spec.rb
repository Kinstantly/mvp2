require 'spec_helper'

describe Category do
	before(:each) do
		@category = Category.new # FactoryGirl products don't have callbacks!
		@category.name = 'THERAPISTS & PARENTING COACHES'
	end
	
	# Integer attributes will be set to 0 if you try to give them a non-numeric value,
	# so no use testing here for numericality.
	
	it "has a name" do
		@category.save.should be_true
	end
	
	it "strips whitespace from the name" do
		name = 'MUSIC TEACHERS'
		@category.name = " #{name} "
		@category.should have(:no).errors_on(:name)
		@category.name.should == name
	end
	
	it "can be flagged as predefined" do
		@category.is_predefined = true
		@category.see_all_column = 1 # required if predefined
		@category.save.should be_true
		Category.predefined.include?(@category).should be_true
	end
	
	it "can be shown in the second column of the home page" do
		@category.home_page_column = 2
		@category.should have(:no).errors_on(:home_page_column)
	end
	
	it "can be shown in the third column of the see-all page" do
		@category.see_all_column = 3
		@category.should have(:no).errors_on(:see_all_column)
	end
	
	it "must display on the see-all page if predefined" do
		@category.is_predefined = true
		@category.see_all_column = nil
		@category.should have(1).error_on(:see_all_column)
	end
	
	context "services" do
		before(:each) do
			@services = [FactoryGirl.create(:service, name: 'couples/family therapists'),
				FactoryGirl.create(:service, name: 'occupational therapists')]
			@category.services = @services
			@category.save
			@category = Category.find_by_name @category.name
		end
		
		it "it has persistent associated services" do
			@services.each do |svc|
				@category.services.include?(svc).should be_true
			end
		end
		
		it "can supply a list of services that are eligible for assigning to itself" do
			predefined_services = [FactoryGirl.create(:predefined_service, name: 'music tutor'),
				FactoryGirl.create(:predefined_service, name: 'math tutor')]
			assignable_services = @category.assignable_services
			@category.services.each do |svc|
				assignable_services.include?(svc).should be_true
			end
			predefined_services.each do |svc|
				assignable_services.include?(svc).should be_true
			end
		end
	end
	
	context "Sunspot/SOLR auto-indexing" do
		before(:each) do
			@category.save
			@profile = FactoryGirl.create(:published_profile, categories: [@category])
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a category, reindexes search for any profiles that contain it" do
			new_name = 'HEALTH'
			Profile.fuzzy_search(new_name).results.include?(@profile).should be_false
			@category.name = new_name
			@category.save
			Sunspot.commit
			Profile.fuzzy_search(new_name).results.include?(@profile).should be_true
		end
		
		it "should not be searchable after trashing" do
			name = @category.name
			Profile.fuzzy_search(name).results.include?(@profile).should be_true
			@category.trash = true
			@category.save
			Sunspot.commit
			Profile.fuzzy_search(name).results.include?(@profile).should be_false
		end
	end
end
