require 'spec_helper'

describe SearchTerm, :type => :model do
	before(:each) do
		@search_term = SearchTerm.new # FactoryGirl products don't have callbacks!
		@search_term.name = 'social skills play groups'
	end
	
	it "has a name" do
		expect(@search_term.save).to be_truthy
	end
	
	it "strips whitespace from the name" do
		name = 'music instruction'
		@search_term.name = " #{name} "
		expect(@search_term).to have(:no).errors_on(:name)
		expect(@search_term.name).to eq name
	end
	
	context "Sunspot/SOLR auto-indexing" do
		before(:each) do
			@search_term.save
			@specialty = FactoryGirl.create(:specialty, search_terms: [@search_term])
			@profile = FactoryGirl.create(:published_profile, specialties: [@specialty])
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a search term, reindexes search for any profiles that contain it" do
			new_name = 'making eye contact'
			expect(Profile.fuzzy_search(new_name).results.include?(@profile)).to be_falsey
			@search_term.name = new_name
			@search_term.save
			Sunspot.commit
			expect(Profile.fuzzy_search(new_name).results.include?(@profile)).to be_truthy
		end
		
		it "should not be searchable after trashing" do
			name = @search_term.name
			expect(Profile.fuzzy_search(name).results.include?(@profile)).to be_truthy
			@search_term.trash = true
			@search_term.save
			Sunspot.commit
			expect(Profile.fuzzy_search(name).results.include?(@profile)).to be_falsey
		end
	end
end
