require 'spec_helper'

describe Service do
	before(:each) do
		@service = Service.new
		@service.name = 'child psychiatrist'
	end
	
	it "has a name" do
		@service.save.should be_true
	end
	
	it "can be flagged as predefined" do
		@service.is_predefined = true
		@service.save.should be_true
		Service.predefined.include?(@service).should be_true
	end
	
	context "specialties" do
		before(:each) do
			@specialties = [FactoryGirl.create(:specialty, name: 'behavior'),
				FactoryGirl.create(:specialty, name: 'adoption')]
			@service.specialties = @specialties
			@service.save
			@service = Service.find_by_name @service.name
		end
		
		it "it has persistent associated specialties" do
			@specialties.each do |spec|
				@service.specialties.include?(spec).should be_true
			end
		end
	end
end
