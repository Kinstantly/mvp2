require 'spec_helper'

describe AgeRange, :type => :model do
	it "has a name" do
		age_range = AgeRange.new
		age_range.name = '0-3'
		expect(age_range.save).to be_truthy
	end
	
	it "has a sort index" do
		age_range = AgeRange.new
		age_range.sort_index = 1
		expect(age_range.save).to be_truthy
	end
end
