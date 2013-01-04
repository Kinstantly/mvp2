require 'spec_helper'

describe SearchAreaTag do
	it "has a name" do
		@tag = SearchAreaTag.new
		@tag.name = 'South Bay'
		@tag.save.should be_true
	end
end
