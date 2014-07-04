require 'spec_helper'

describe ServiceSubcategory do
	let(:service_subcategory) { FactoryGirl.create :service_subcategory }
	
	it "references a service" do
		service_subcategory.should respond_to :service
	end
	
	it "references a subcategory" do
		service_subcategory.should respond_to :subcategory
	end
	
	it "specifies a display order for the service within the subcategory" do
		service_subcategory.should respond_to :service_display_order
	end
end
