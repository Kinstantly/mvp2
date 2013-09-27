require 'spec_helper'

describe Specialty do
	before(:each) do
		@specialty = Specialty.new # FactoryGirl products don't have callbacks!
		@specialty.name = 'behavior'
	end
	
	it "has a name" do
		@specialty.save.should be_true
	end
	
	it "strips whitespace from the name" do
		name = 'music instruction'
		@specialty.name = " #{name} "
		@specialty.should have(:no).errors_on(:name)
		@specialty.name.should == name
	end
	
	it "can be flagged as predefined" do
		@specialty.is_predefined = true
		@specialty.save.should be_true
		Specialty.predefined.include?(@specialty).should be_true
	end
	
	context "search terms" do
		before(:each) do
			@search_terms = [FactoryGirl.create(:search_term, name: 'oppositional behavior'),
				FactoryGirl.create(:search_term, name: 'defiant teens')]
			@specialty.search_terms = @search_terms
			@specialty.save
			@specialty = Specialty.find_by_name @specialty.name
		end
		
		it "it has persistent associated search terms" do
			@search_terms.each do |spec|
				@specialty.search_terms.include?(spec).should be_true
			end
		end
		
		it "can add a search term by name" do
			@specialty.search_term_names_to_add = ['bored teens']
			@specialty.save
			Specialty.find(@specialty.id).search_terms.include?('bored teens'.to_search_term).should be_true
		end
		
		it "can remove a search term by id" do
			@specialty.search_term_ids_to_remove = [@search_terms[0].id.to_s]
			@specialty.save
			@specialty = Specialty.find(@specialty.id)
			@specialty.search_terms.include?(@search_terms[0]).should_not be_true
			@specialty.search_terms.include?(@search_terms[1]).should be_true
		end
	end
	
	context "Sunspot/SOLR auto-indexing" do
		before(:each) do
			@specialty.save
			@profile = FactoryGirl.create(:published_profile, specialties: [@specialty])
			Profile.reindex # reset the SOLR index
			Sunspot.commit
		end
		
		it "after modifying a specialty, reindexes search for any profiles that contain it" do
			new_name = 'peer social skills'
			Profile.fuzzy_search(new_name).results.include?(@profile).should be_false
			@specialty.name = new_name
			@specialty.save
			Sunspot.commit
			Profile.fuzzy_search(new_name).results.include?(@profile).should be_true
		end
		
		it "should not be searchable after trashing" do
			name = @specialty.name
			Profile.fuzzy_search(name).results.include?(@profile).should be_true
			@specialty.trash = true
			@specialty.save
			Sunspot.commit
			Profile.fuzzy_search(name).results.include?(@profile).should be_false
		end
		
		it "after adding an existing search term, reindexes search for any profiles that contain it" do
			new_name = 'making eye contact'
			Profile.fuzzy_search(new_name).results.include?(@profile).should be_false
			@specialty.search_terms << new_name.to_search_term
			Sunspot.commit
			Profile.fuzzy_search(new_name).results.include?(@profile).should be_true
		end
	end
end
