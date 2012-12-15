require 'spec_helper'

describe Category do
	before(:each) do
		@category = Category.new
		@category.name = 'THERAPISTS & PARENTING COACHES'
	end
	
	it "has a name" do
		@category.save.should be_true
	end
	
	it "can be flagged as predefined" do
		@category.is_predefined = true
		@category.save.should be_true
		Category.predefined.include?(@category).should be_true
	end
	
	context "services" do
		before(:each) do
			@services = [FactoryGirl.create(:service, name: 'couples/family therapists'),
				FactoryGirl.create(:service, name: 'occupational therapists')]
			@category.services = @services
			@category.save
			@category = Category.find_by_name @category.name
		end
		
		it "it has persistent associated services" do
			@services.each do |spec|
				@category.services.include?(spec).should be_true
			end
		end
	end
end
