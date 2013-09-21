require 'spec_helper'

describe SearchTerm do
	before(:each) do
		@search_term = SearchTerm.new # FactoryGirl products don't have callbacks!
		@search_term.name = 'social skills play groups'
	end
	
	it "has a name" do
		@search_term.save.should be_true
	end
	
	it "strips whitespace from the name" do
		name = 'music instruction'
		@search_term.name = " #{name} "
		@search_term.should have(:no).errors_on(:name)
		@search_term.name.should == name
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
			Profile.fuzzy_search(new_name).results.include?(@profile).should be_false
			@search_term.name = new_name
			@search_term.save
			Sunspot.commit
			Profile.fuzzy_search(new_name).results.include?(@profile).should be_true
		end
		
		it "should not be searchable after trashing" do
			name = @search_term.name
			Profile.fuzzy_search(name).results.include?(@profile).should be_true
			@search_term.trash = true
			@search_term.save
			Sunspot.commit
			Profile.fuzzy_search(name).results.include?(@profile).should be_false
		end
	end
end
