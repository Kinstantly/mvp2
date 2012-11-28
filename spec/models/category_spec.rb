require 'spec_helper'

describe Category do
	before(:each) do
		@category = Category.new
		@category.name = 'child psychiatrist'
	end
	
	it "has a name" do
		@category.save.should be_true
	end
	
	it "can be flagged as predefined" do
		@category.is_predefined = true
		@category.save.should be_true
		Category.predefined.include?(@category).should be_true
	end
	
	context "specialties" do
		before(:each) do
			@specialties = [FactoryGirl.create(:specialty, name: 'behavior'),
				FactoryGirl.create(:specialty, name: 'adoption')]
			@category.specialties = @specialties
			@category.save
			@category = Category.find_by_name @category.name
		end
		
		it "it has persistent associated specialties" do
			@specialties.each do |spec|
				@category.specialties.include?(spec).should be_true
			end
		end
		
		it "has a map of all associated specialties" do
			Category.specialties_map[@category.id].sort_by(&:id).should == @specialties.sort_by(&:id)
		end
	end
end
