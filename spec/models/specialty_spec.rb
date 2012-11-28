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
end
