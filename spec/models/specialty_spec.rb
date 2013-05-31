require 'spec_helper'

describe Specialty do
	before(:each) do
		@specialty = Specialty.new
		@specialty.name = 'behavior'
	end
	
	it "has a name" do
		@specialty.save.should be_true
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
	end
end
