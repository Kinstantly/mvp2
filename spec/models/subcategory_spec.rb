require 'spec_helper'

describe Subcategory do
	# FactoryGirl products don't have callbacks, so let's build it ourselves!
	let(:subcategory) { Subcategory.new name: 'CHILD & FAMILY' }
	
	# Integer attributes will be set to 0 if you try to give them a non-numeric value,
	# so no use testing here for numericality.
	
	it "has a name" do
		subcategory.save.should be_true
	end
	
	it "strips whitespace from the name" do
		name = 'CHILD CARE'
		subcategory.name = " #{name} "
		subcategory.should have(:no).errors_on(:name)
		subcategory.name.should == name
	end

	it "can be trashed" do
		subcategory.save # Make persistent.
		expect {
			subcategory.trash = true
			subcategory.save
		}.to change(Subcategory, :count).by(-1)
	end
	
	# it "can be flagged as predefined" do
	# 	subcategory.is_predefined = true
	# 	subcategory.see_all_column = 1 # required if predefined
	# 	subcategory.save.should be_true
	# 	Subcategory.predefined.include?(subcategory).should be_true
	# end
	
	context "services" do
		let(:services) {
			[FactoryGirl.create(:service, name: 'Art Therapists'),
				FactoryGirl.create(:service, name: 'Occupational Therapists')]
		}
		
		before(:each) do
			subcategory.services = services
			subcategory.save
			subcategory.reload
		end
		
		it "it has persistent associated services" do
			services.each do |svc|
				subcategory.services.include?(svc).should be_true
			end
		end
		
		it "can supply a list of services that are eligible for assigning to itself" do
			predefined_services = [FactoryGirl.create(:predefined_service, name: 'Music Tutors'),
				FactoryGirl.create(:predefined_service, name: 'Math Tutors')]
			assignable_services = subcategory.assignable_services
			subcategory.services.each do |svc|
				assignable_services.include?(svc).should be_true
			end
			predefined_services.each do |svc|
				assignable_services.include?(svc).should be_true
			end
		end
	end
	
	context "Sunspot/SOLR auto-indexing" do
		let(:profile) {
			subcategory.save if subcategory.new_record?
			FactoryGirl.create(:published_profile, subcategories: [subcategory])
		}
		
		before(:each) do
			profile # Instantiate!
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a subcategory, reindexes search for any profiles that contain it" do
			new_name = 'COUPLES/ADULT'
			Profile.fuzzy_search(new_name).results.include?(profile).should be_false
			subcategory.name = new_name
			subcategory.save
			Sunspot.commit
			Profile.fuzzy_search(new_name).results.include?(profile).should be_true
		end
		
		it "should not be searchable after trashing" do
			name = subcategory.name
			Profile.fuzzy_search(name).results.include?(profile).should be_true
			subcategory.trash = true
			subcategory.save
			Sunspot.commit
			Profile.fuzzy_search(name).results.include?(profile).should be_false
		end
	end
end
