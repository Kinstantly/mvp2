require 'spec_helper'

describe Service do
	# FactoryGirl products don't have callbacks!
	let(:service) { Service.new name: 'child psychiatrist' }
	
	# Integer attributes will be set to 0 if you try to give them a non-numeric value,
	# so no use testing here for numericality.
	
	it "has a name" do
		service.save.should be_true
	end
	
	it "strips whitespace from the name" do
		name = 'music teacher'
		service.name = " #{name} "
		service.should have(:no).errors_on(:name)
		service.name.should == name
	end
	
	it "can be flagged as predefined" do
		service.is_predefined = true
		service.save.should be_true
		Service.predefined.include?(service).should be_true
	end
	
	it "can be shown on the home page" do
		service.show_on_home_page = true
		service.should have(:no).errors_on(:show_on_home_page)
	end
	
	context "finding services that belong to a subcategory" do
		let(:subcategory) { FactoryGirl.create(:subcategory, name: 'psychiatrists') }
		
		before(:each) do
			service.save
		end
		
		it "does not belong to a subcategory" do
			Service.belongs_to_a_subcategory.include?(service).should be_false
		end
		
		it "belongs to a subcategory" do
			subcategory.services << service
			Service.belongs_to_a_subcategory.include?(service).should be_true
		end
	end
	
	
	context "specialties" do
		let(:specialties) {
			[FactoryGirl.create(:specialty, name: 'behavior'),
				FactoryGirl.create(:specialty, name: 'adoption')]
		}
		
		before(:each) do
			service.specialties = specialties
			service.save
			service.reload
		end
		
		it "it has persistent associated specialties" do
			specialties.each do |spec|
				service.specialties.include?(spec).should be_true
			end
		end
		
		it "can supply a list of specialties that are eligible for assigning to itself" do
			predefined_specialties = [FactoryGirl.create(:predefined_specialty, name: 'banjo'),
				FactoryGirl.create(:predefined_specialty, name: 'algebra')]
			assignable_specialties = service.assignable_specialties
			service.specialties.each do |spec|
				assignable_specialties.include?(spec).should be_true
			end
			predefined_specialties.each do |spec|
				assignable_specialties.include?(spec).should be_true
			end
		end
	end
	
	context "Sunspot/SOLR auto-indexing" do
		let(:profile) {
			service.save
			FactoryGirl.create(:published_profile, services: [service])
		}
		
		before(:each) do
			profile # Instantiate a profile for indexing into Solr.
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a service, reindexes search for any profiles that contain it" do
			new_name = 'Social Skills Therapists'
			Profile.fuzzy_search(new_name).results.include?(profile).should be_false
			service.name = new_name
			service.save
			Sunspot.commit
			Profile.fuzzy_search(new_name).results.include?(profile).should be_true
		end
		
		it "should not be searchable after trashing" do
			name = service.name
			Profile.fuzzy_search(name).results.include?(profile).should be_true
			service.trash = true
			service.save
			Sunspot.commit
			Profile.fuzzy_search(name).results.include?(profile).should be_false
		end
	end
end
