require 'spec_helper'

describe "home/show_all_categories" do
	let(:service) { FactoryGirl.create :predefined_service }
	let(:category) { FactoryGirl.create :predefined_category, services: [service] }
	
	before(:each) do
		category # make sure we have the category and service
	end
	
	it "should show all categories" do
		render
		rendered.should have_content(category.name)
	end
	
	it "should show services for all categories" do
		render
		rendered.should have_content(service.name)
	end
end
