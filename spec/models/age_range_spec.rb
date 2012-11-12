require 'spec_helper'

describe AgeRange do
	it "has a name" do
		age_range = AgeRange.new
		age_range.name = '0-3'
		age_range.save.should be_true
	end
	
	it "has a sort index" do
		age_range = AgeRange.new
		age_range.sort_index = 1
		age_range.save.should be_true
	end
end
