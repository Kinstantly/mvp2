require 'spec_helper'

describe Profile do
	before(:each) do
		@profile = Profile.new
	end
	
	context "name" do
		it "should be happy if we set both first and last name" do
			@profile.first_name = 'Joe'
			@profile.last_name = 'Black'
			@profile.should have(:no).errors_on(:first_name)
			@profile.should have(:no).errors_on(:last_name)
		end
		
		it "complain if first and last name not set" do
			@profile.should have(1).errors_on(:first_name)
			@profile.should have(1).errors_on(:last_name)
		end
	end
end
