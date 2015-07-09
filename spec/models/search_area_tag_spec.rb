require 'spec_helper'

describe SearchAreaTag, :type => :model do
	it "has a name" do
		@tag = SearchAreaTag.new
		@tag.name = 'South Bay'
		expect(@tag.save).to be_truthy
	end
end
