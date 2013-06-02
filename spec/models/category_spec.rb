require 'spec_helper'

describe Category do
	before(:each) do
		@category = Category.new # FactoryGirl products don't have callbacks!
		@category.name = 'THERAPISTS & PARENTING COACHES'
	end
	
	it "has a name" do
		@category.save.should be_true
	end
	
	it "can be flagged as predefined" do
		@category.is_predefined = true
		@category.save.should be_true
		Category.predefined.include?(@category).should be_true
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
			@services.each do |spec|
				@category.services.include?(spec).should be_true
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
