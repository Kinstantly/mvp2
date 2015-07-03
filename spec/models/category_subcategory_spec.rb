require 'spec_helper'

describe CategorySubcategory, :type => :model do
	let(:category_subcategory) { FactoryGirl.create :category_subcategory }
	
	it "references a category" do
		expect(category_subcategory).to respond_to :category
	end
	
	it "references a subcategory" do
		expect(category_subcategory).to respond_to :subcategory
	end
	
	it "specifies a display order for the subcategory within the category" do
		expect(category_subcategory).to respond_to :subcategory_display_order
	end
end
