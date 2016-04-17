require 'spec_helper'

describe Service, :type => :model do
	# FactoryGirl products don't have callbacks!
	let(:service) { Service.new name: 'child psychiatrist' }
	
	# Integer attributes will be set to 0 if you try to give them a non-numeric value,
	# so no use testing here for numericality.
	
	it "has a name" do
		service.name = 'bouncy houses'
		expect(service.errors_on(:name)).to be_empty
	end
	
	it "strips whitespace from the name" do
		name = 'music teacher'
		service.name = " #{name} "
		expect(service.errors_on(:name)).to be_empty
		expect(service.name).to eq name
	end
	
	it "can be trashed" do
		service.save # Make persistent.
		expect {
			service.trash = true
			service.save
		}.to change(Service, :count).by(-1)
	end
	
	it 'can be found in the trash' do
		service.trash = true
		service.save
		expect(Service.trash.include?(service)).to be_truthy
	end
	
	it 'can be ordered by name' do
		service_B = FactoryGirl.create :service, name: 'B'
		service_A = FactoryGirl.create :service, name: 'A'
		expect(Service.order_by_name.first).to eq service_A
		expect(Service.order_by_name.last).to eq service_B
	end
	
	it 'can be ordered for display' do
		service_to_display_last = FactoryGirl.create :service, display_order: 99
		service_to_display_first = FactoryGirl.create :service, display_order: 1
		expect(Service.display_order.first).to eq service_to_display_first
		expect(Service.display_order.last).to eq service_to_display_last
	end
	
	it "can be flagged as predefined" do
		service.is_predefined = false
		service.save
		expect {
			service.is_predefined = true
			service.save
		}.to change { Service.predefined.include?(service) }.from(false).to(true)
	end
	
	it "can be shown on the home page" do
		service.show_on_home_page = false
		service.save
		expect {
			service.show_on_home_page = true
			service.save
		}.to change { Service.for_home_page.include?(service) }.from(false).to(true)
	end
	
	context "finding services that belong to a subcategory" do
		let(:subcategory) { FactoryGirl.create(:subcategory, name: 'psychiatrists') }
		
		before(:example) do
			service.save
			subcategory
		end
		
		it "can be added to a subcategory" do
			expect {
				subcategory.services << service
			}.to change { Service.belongs_to_a_subcategory.include?(service) }.from(false).to(true)
		end
	end
	
	context "specialties" do
		let(:specialties) {
			[FactoryGirl.create(:specialty, name: 'behavior'),
				FactoryGirl.create(:specialty, name: 'adoption')]
		}
		
		before(:example) do
			service.specialties = specialties
			service.save
			service.reload
		end
		
		it "it has persistent associated specialties" do
			specialties.each do |spec|
				expect(service.specialties.include?(spec)).to be_truthy
			end
		end
		
		it "can supply a list of specialties that are eligible for assigning to itself" do
			predefined_specialties = [FactoryGirl.create(:predefined_specialty, name: 'banjo'),
				FactoryGirl.create(:predefined_specialty, name: 'algebra')]
			assignable_specialties = service.assignable_specialties
			service.specialties.each do |spec|
				expect(assignable_specialties.include?(spec)).to be_truthy
			end
			predefined_specialties.each do |spec|
				expect(assignable_specialties.include?(spec)).to be_truthy
			end
		end
	end
	
	context "Sunspot/SOLR auto-indexing" do
		let(:profile) {
			service.save
			FactoryGirl.create(:published_profile, services: [service])
		}
		
		before(:example) do
			profile # Instantiate a profile for indexing into Solr.
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a service, reindexes search for any profiles that contain it" do
			new_name = 'Social Skills Therapists'
			expect(Profile.fuzzy_search(new_name).results.include?(profile)).to be_falsey
			service.name = new_name
			service.save
			Sunspot.commit
			expect(Profile.fuzzy_search(new_name).results.include?(profile)).to be_truthy
		end
		
		it "should not be searchable after trashing" do
			name = service.name
			expect(Profile.fuzzy_search(name).results.include?(profile)).to be_truthy
			service.trash = true
			service.save
			Sunspot.commit
			expect(Profile.fuzzy_search(name).results.include?(profile)).to be_falsey
		end
	end
end
