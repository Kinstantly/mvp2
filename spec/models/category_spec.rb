require 'spec_helper'

describe Category, :type => :model do
	# FactoryGirl products don't have callbacks!
	let(:category) { Category.new name: 'ACTIVITIES' }
	let(:another_category) { Category.new name: 'THERAPY' }
	
	# Integer attributes will be set to 0 if you try to give them a non-numeric value,
	# so no use testing here for numericality.
	
	it "has a name" do
		expect(category.save).to be_truthy
	end
	
	it "strips whitespace from the name" do
		name = 'FAMILY SERVICES'
		category.name = " #{name} "
		category.valid?
		expect(category.errors[:name].size).to eq 0
		expect(category.name).to eq name
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
		expect(category.save).to be_truthy
		expect(Category.predefined.include?(category)).to be_truthy
	end
	
	it "can be shown in the second column of the home page" do
		category.home_page_column = 2
		category.valid?
		expect(category.errors[:home_page_column].size).to eq 0
	end
	
	it "can be shown in the third column of the see-all page" do
		category.see_all_column = 3
		category.valid?
		expect(category.errors[:see_all_column].size).to eq 0
	end
	
	# it "must display on the see-all page if predefined" do
	# 	category.is_predefined = true
	# 	category.see_all_column = nil
	# 	category.valid?
	# 	expect(category.errors[:see_all_column].size).to eq 1
	# end
	
	it 'can be sorted by name' do
		category.name = 'B'
		category.save
		another_category.name = 'A'
		another_category.save
		expect(Category.order_by_name.first).to eq another_category
		expect(Category.order_by_name.last).to eq category
	end
	
	it 'can be sorted by display order' do
		category.display_order = 99
		category.save
		another_category.display_order = 1
		another_category.save
		expect(Category.display_order.first).to eq another_category
		expect(Category.display_order.last).to eq category
	end
	
	it 'can be sorted by home page column' do
		category.home_page_column = 2
		category.save
		another_category.home_page_column = 1
		another_category.save
		expect(Category.home_page_order.first).to eq another_category
		expect(Category.home_page_order.last).to eq category
	end
	
	context "category lists" do
		before(:example) do
			category.is_predefined = true
		end
		
		it "belongs to home-category list if flagged to display on the home page" do
			category.home_page_column = 1
			expect(category.save).to be_truthy
			expect(category.reload.category_lists.include?(CategoryList.home_list)).to be_truthy
		end
		
		it "does not belong to home-category list if removed from the home page" do
			category.home_page_column = 1
			expect(category.save).to be_truthy
			category.home_page_column = nil
			expect(category.save).to be_truthy
			expect(category.reload.category_lists.include?(CategoryList.home_list)).not_to be_truthy
		end
		
		it "belongs to the all-category list if predefined" do
			expect(category.save).to be_truthy
			expect(category.reload.category_lists.include?(CategoryList.all_list)).to be_truthy
		end
		
		it "does not belong to the all-category list if no longer predefined" do
			expect(category.save).to be_truthy
			category.is_predefined = false
			expect(category.save).to be_truthy
			expect(category.reload.category_lists.include?(CategoryList.all_list)).not_to be_truthy
		end
	end
	
	context "subcategories" do
		let(:subcategories) {
			[FactoryGirl.create(:subcategory, name: 'SPORTS'),
				FactoryGirl.create(:subcategory, name: 'CAMPS')]
		}
		
		before(:example) do
			category.subcategories = subcategories
			category.save
			category.reload
		end
		
		it "it has persistent associated subcategories" do
			subcategories.each do |svc|
				expect(category.subcategories.include?(svc)).to be_truthy
			end
		end
		
		# it "can supply a list of subcategories that are eligible for assigning to itself" do
		# 	predefined_subcategories = [FactoryGirl.create(:subcategory, name: 'FAMILY OUTINGS'),
		# 		FactoryGirl.create(:subcategory, name: 'ENRICHMENT CLASSES & LESSONS')]
		# 	assignable_subcategories = category.assignable_subcategories
		# 	category.subcategories.each do |svc|
		# 		assignable_subcategories.include?(svc).should be_true
		# 	end
		# 	predefined_subcategories.each do |svc|
		# 		assignable_subcategories.include?(svc).should be_true
		# 	end
		# end
	end
	
	context "Sunspot/SOLR auto-indexing" do
		let(:profile) {
			category.save if category.new_record?
			FactoryGirl.create(:published_profile, categories: [category])
		}
		
		before(:example) do
			profile # Instantiate!
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a category, reindexes search for any profiles that contain it" do
			new_name = 'HEALTH'
			expect(Profile.fuzzy_search(new_name).results.include?(profile)).to be_falsey
			category.name = new_name
			category.save
			Sunspot.commit
			expect(Profile.fuzzy_search(new_name).results.include?(profile)).to be_truthy
		end
		
		it "should not be searchable after trashing" do
			name = category.name
			expect(Profile.fuzzy_search(name).results.include?(profile)).to be_truthy
			category.trash = true
			category.save
			Sunspot.commit
			expect(Profile.fuzzy_search(name).results.include?(profile)).to be_falsey
		end
	end
end
