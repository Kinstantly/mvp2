require 'spec_helper'

describe Profile do
	before(:each) do
		@profile = Profile.new
		@profile.first_name = 'Joe'
		@profile.last_name = 'Black'
	end
	
	context "name" do
		it "is happy if we set both first and last name" do
			@profile.should have(:no).errors_on(:first_name)
			@profile.should have(:no).errors_on(:last_name)
		end
		
		it "complains if first and last name are not set" do
			@profile.first_name = ''
			@profile.last_name = ''
			@profile.should have(1).errors_on(:first_name)
			@profile.should have(1).errors_on(:last_name)
		end
	end
	
	context "categories" do
		it "stores multiple categories" do
			categories = ['board-certified behavior analyst', 'child/clinical psychologist']
			@profile.categories = categories
			@profile.save.should == true
			@profile.categories.should == categories
		end
	end
end
