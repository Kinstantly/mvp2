require 'spec_helper'

describe AgeRange do
	it "has a name" do
		age_range = AgeRange.new
		age_range.name = '0-3'
		age_range.save.should == true
	end
end
