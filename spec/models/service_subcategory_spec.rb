require 'spec_helper'

describe ServiceSubcategory, :type => :model do
	let(:service_subcategory) { FactoryGirl.create :service_subcategory }
	
	it "references a service" do
		expect(service_subcategory).to respond_to :service
	end
	
	it "references a subcategory" do
		expect(service_subcategory).to respond_to :subcategory
	end
	
	it "specifies a display order for the service within the subcategory" do
		expect(service_subcategory).to respond_to :service_display_order
	end
end
