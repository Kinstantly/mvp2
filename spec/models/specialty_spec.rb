require 'spec_helper'

describe Specialty, :type => :model do
	before(:each) do
		@specialty = Specialty.new # FactoryGirl products don't have callbacks!
		@specialty.name = 'behavior'
	end
	
	it "has a name" do
		expect(@specialty.save).to be_truthy
	end
	
	it "strips whitespace from the name" do
		name = 'music instruction'
		@specialty.name = " #{name} "
		expect(@specialty).to have(:no).errors_on(:name)
		expect(@specialty.name).to eq name
	end
	
	it "can be flagged as predefined" do
		@specialty.is_predefined = true
		expect(@specialty.save).to be_truthy
		expect(Specialty.predefined.include?(@specialty)).to be_truthy
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
				expect(@specialty.search_terms.include?(spec)).to be_truthy
			end
		end
		
		it "can add a search term by name" do
			@specialty.search_term_names_to_add = ['bored teens']
			@specialty.save
			expect(Specialty.find(@specialty.id).search_terms.include?('bored teens'.to_search_term)).to be_truthy
		end
		
		it "can remove a search term by id" do
			@specialty.search_term_ids_to_remove = [@search_terms[0].id.to_s]
			@specialty.save
			@specialty = Specialty.find(@specialty.id)
			expect(@specialty.search_terms.include?(@search_terms[0])).not_to be_truthy
			expect(@specialty.search_terms.include?(@search_terms[1])).to be_truthy
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
			expect(Profile.fuzzy_search(new_name).results.include?(@profile)).to be_falsey
			@specialty.name = new_name
			@specialty.save
			Sunspot.commit
			expect(Profile.fuzzy_search(new_name).results.include?(@profile)).to be_truthy
		end
		
		it "should not be searchable after trashing" do
			name = @specialty.name
			expect(Profile.fuzzy_search(name).results.include?(@profile)).to be_truthy
			@specialty.trash = true
			@specialty.save
			Sunspot.commit
			expect(Profile.fuzzy_search(name).results.include?(@profile)).to be_falsey
		end
		
		it "after adding an existing search term, reindexes search for any profiles that contain it" do
			new_name = 'making eye contact'
			expect(Profile.fuzzy_search(new_name).results.include?(@profile)).to be_falsey
			@specialty.search_terms << new_name.to_search_term
			Sunspot.commit
			expect(Profile.fuzzy_search(new_name).results.include?(@profile)).to be_truthy
		end
	end
end
