require 'spec_helper'

describe Specialty do
	it "has a name" do
		specialty = Specialty.new
		specialty.name = 'behavior'
		specialty.save.should == true
	end
end
