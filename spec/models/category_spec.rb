require 'spec_helper'

describe Category do
	# FactoryGirl products don't have callbacks!
	let(:category) { Category.new name: 'ACTIVITIES' }
	
	# Integer attributes will be set to 0 if you try to give them a non-numeric value,
	# so no use testing here for numericality.
	
	it "has a name" do
		category.save.should be_true
	end
	
	it "strips whitespace from the name" do
		name = 'FAMILY SERVICES'
		category.name = " #{name} "
		category.should have(:no).errors_on(:name)
		category.name.should == name
	end

	it "can be trashed" do
		category.save # Make persistent.
		expect {
			category.trash = true
			category.save
		}.to change(Category, :count).by(-1)
	end
	
	it "can be flagged as predefined" do
		category.is_predefined = true
		category.see_all_column = 1 # required if predefined
		category.save.should be_true
		Category.predefined.include?(category).should be_true
	end
	
	it "can be shown in the second column of the home page" do
		category.home_page_column = 2
		category.should have(:no).errors_on(:home_page_column)
	end
	
	it "can be shown in the third column of the see-all page" do
		category.see_all_column = 3
		category.should have(:no).errors_on(:see_all_column)
	end
	
	it "must display on the see-all page if predefined" do
		category.is_predefined = true
		category.see_all_column = nil
		category.should have(1).error_on(:see_all_column)
	end
	
	context "category lists" do
		before(:each) do
			category.is_predefined = true
		end
		
		it "belongs to home-category list if flagged to display on the home page" do
			category.home_page_column = 1
			category.save.should be_true
			category.reload.category_lists.include?(CategoryList.home_list).should be_true
		end
		
		it "does not belong to home-category list if removed from the home page" do
			category.home_page_column = 1
			category.save.should be_true
			category.home_page_column = nil
			category.save.should be_true
			category.reload.category_lists.include?(CategoryList.home_list).should_not be_true
		end
		
		it "belongs to the all-category list if predefined" do
			category.save.should be_true
			category.reload.category_lists.include?(CategoryList.all_list).should be_true
		end
		
		it "does not belong to the all-category list if no longer predefined" do
			category.save.should be_true
			category.is_predefined = false
			category.save.should be_true
			category.reload.category_lists.include?(CategoryList.all_list).should_not be_true
		end
	end
	
	context "subcategories" do
		let(:subcategories) {
			[FactoryGirl.create(:subcategory, name: 'SPORTS'),
				FactoryGirl.create(:subcategory, name: 'CAMPS')]
		}
		
		before(:each) do
			category.subcategories = subcategories
			category.save
			category.reload
		end
		
		it "it has persistent associated subcategories" do
			subcategories.each do |svc|
				category.subcategories.include?(svc).should be_true
			end
		end
		
		it "can supply a list of subcategories that are eligible for assigning to itself" do
			predefined_subcategories = [FactoryGirl.create(:predefined_subcategory, name: 'FAMILY OUTINGS'),
				FactoryGirl.create(:predefined_subcategory, name: 'ENRICHMENT CLASSES & LESSONS')]
			assignable_subcategories = category.assignable_subcategories
			category.subcategories.each do |svc|
				assignable_subcategories.include?(svc).should be_true
			end
			predefined_subcategories.each do |svc|
				assignable_subcategories.include?(svc).should be_true
			end
		end
	end
	
	context "Sunspot/SOLR auto-indexing" do
		let(:profile) {
			category.save if category.new_record?
			FactoryGirl.create(:published_profile, categories: [category])
		}
		
		before(:each) do
			profile # Instantiate!
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a category, reindexes search for any profiles that contain it" do
			new_name = 'HEALTH'
			Profile.fuzzy_search(new_name).results.include?(profile).should be_false
			category.name = new_name
			category.save
			Sunspot.commit
			Profile.fuzzy_search(new_name).results.include?(profile).should be_true
		end
		
		it "should not be searchable after trashing" do
			name = category.name
			Profile.fuzzy_search(name).results.include?(profile).should be_true
			category.trash = true
			category.save
			Sunspot.commit
			Profile.fuzzy_search(name).results.include?(profile).should be_false
		end
	end
end
