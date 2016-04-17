require 'spec_helper'

describe SearchTerm, :type => :model do
	let(:search_term) {
		search_term = SearchTerm.new # FactoryGirl products don't have callbacks!
		search_term.name = 'social skills play groups'
		search_term
	}
	
	it "has a name" do
		search_term.name = 'fun places'
		expect(search_term.errors_on(:name)).to be_empty
	end
	
	it "strips whitespace from the name" do
		name = 'music instruction'
		search_term.name = " #{name} "
		expect(search_term.errors_on(:name)).to be_empty
		expect(search_term.name).to eq name
	end
	
	it "can be trashed" do
		search_term.save # Make persistent.
		expect {
			search_term.trash = true
			search_term.save
		}.to change(SearchTerm, :count).by(-1)
	end
	
	it 'can be found in the trash' do
		search_term.trash = true
		search_term.save
		expect(SearchTerm.trash.include?(search_term)).to be_truthy
	end
	
	it 'can be ordered by name' do
		search_term_B = FactoryGirl.create :search_term, name: 'B'
		search_term_A = FactoryGirl.create :search_term, name: 'A'
		expect(SearchTerm.order_by_name.first).to eq search_term_A
		expect(SearchTerm.order_by_name.last).to eq search_term_B
	end
	
	context "Sunspot/SOLR auto-indexing" do
		let(:specialty) {
			search_term.save
			FactoryGirl.create(:specialty, search_terms: [search_term])
		}
		let(:profile) { FactoryGirl.create(:published_profile, specialties: [specialty]) }
		
		before(:example) do
			profile # Create a profile.
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a search term, reindexes search for any profiles that contain it" do
			new_name = 'making eye contact'
			expect(Profile.fuzzy_search(new_name).results.include?(profile)).to be_falsey
			search_term.name = new_name
			search_term.save
			Sunspot.commit
			expect(Profile.fuzzy_search(new_name).results.include?(profile)).to be_truthy
		end
		
		it "should not be searchable after trashing" do
			name = search_term.name
			expect(Profile.fuzzy_search(name).results.include?(profile)).to be_truthy
			search_term.trash = true
			search_term.save
			Sunspot.commit
			expect(Profile.fuzzy_search(name).results.include?(profile)).to be_falsey
		end
	end
end
