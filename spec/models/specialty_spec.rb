require 'spec_helper'

describe Specialty, :type => :model do
	let(:specialty) {
		# FactoryGirl products don't have callbacks!
		Specialty.new name: 'behavior'
	}
	
	it "has a name" do
		specialty.name = 'compliant teens'
		expect(specialty.errors_on(:name)).to be_empty
	end
	
	it "strips whitespace from the name" do
		name = 'music instruction'
		specialty.name = " #{name} "
		expect(specialty.errors_on(:name)).to be_empty
		expect(specialty.name).to eq name
	end
	
	it "can be trashed" do
		specialty.save # Make persistent.
		expect {
			specialty.trash = true
			specialty.save
		}.to change(Specialty, :count).by(-1)
	end
	
	it 'can be found in the trash' do
		specialty.trash = true
		specialty.save
		expect(Specialty.trash.include?(specialty)).to be_truthy
	end
	
	it "can be flagged as predefined" do
		specialty.is_predefined = false
		specialty.save
		expect {
			specialty.is_predefined = true
			specialty.save
		}.to change { Specialty.predefined.include?(specialty) }.from(false).to(true)
	end
	
	it 'can be ordered by name' do
		specialty_B = FactoryGirl.create :specialty, name: 'B'
		specialty_A = FactoryGirl.create :specialty, name: 'A'
		expect(Specialty.order_by_name.first).to eq specialty_A
		expect(Specialty.order_by_name.last).to eq specialty_B
	end
	
	context "search terms" do
		let(:search_terms) {
			[
				FactoryGirl.create(:search_term, name: 'oppositional behavior'),
				FactoryGirl.create(:search_term, name: 'defiant teens')
			]
		}
		
		before(:example) do
			specialty.search_terms = search_terms
			specialty.save
			specialty.reload
		end
		
		it "it has persistent associated search terms" do
			search_terms.each do |spec|
				expect(specialty.search_terms.include?(spec)).to be_truthy
			end
		end
		
		it "can add a search term by name" do
			specialty.search_term_names_to_add = ['bored teens']
			specialty.save
			expect(Specialty.find(specialty.id).search_terms.include?('bored teens'.to_search_term)).to be_truthy
		end
		
		it "can remove a search term by id" do
			specialty.search_term_ids_to_remove = [search_terms[0].id.to_s]
			specialty.save
			specialty.reload
			expect(specialty.search_terms.include?(search_terms[0])).not_to be_truthy
			expect(specialty.search_terms.include?(search_terms[1])).to be_truthy
		end
	end
	
	context "Sunspot/SOLR auto-indexing" do
		let(:profile) {
			# Create a profile with the specialty.
			specialty.save # Make persistent.
			specialty.reload
			FactoryGirl.create(:published_profile, specialties: [specialty])
		}
		
		before(:example) do
			profile # Create the profile.
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a specialty, reindexes search for any profiles that contain it" do
			new_name = 'peer social skills'
			expect {
				specialty.name = new_name
				specialty.save
				Sunspot.commit
			}.to change { Profile.fuzzy_search(new_name).results.include?(profile) }.from(false).to(true)
		end
		
		it "should not be searchable after trashing" do
			name = specialty.name
			expect {
				specialty.trash = true
				specialty.save
				Sunspot.commit
			}.to change { Profile.fuzzy_search(name).results.include?(profile) }.from(true).to(false)
		end
		
		it "after adding an existing search term, reindexes search for any profiles that contain it" do
			new_name = 'making eye contact'
			expect {
				specialty.search_terms << new_name.to_search_term
				Sunspot.commit
			}.to change { Profile.fuzzy_search(new_name).results.include?(profile) }.from(false).to(true)
		end
	end
end
