require 'spec_helper'

describe SearchTerm do
	before(:each) do
		@search_term = SearchTerm.new
		@search_term.name = 'social skills play groups'
	end
	
	it "has a name" do
		@search_term.save.should be_true
	end
end
