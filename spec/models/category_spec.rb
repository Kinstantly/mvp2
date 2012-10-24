require 'spec_helper'

describe Category do
	it "has a name" do
		category = Category.new
		category.name = 'Parenting'
		category.save.should == true
	end
end
