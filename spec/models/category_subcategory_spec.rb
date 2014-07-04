require 'spec_helper'

describe CategorySubcategory do
	let(:category_subcategory) { FactoryGirl.create :category_subcategory }
	
	it "references a category" do
		category_subcategory.should respond_to :category
	end
	
	it "references a subcategory" do
		category_subcategory.should respond_to :subcategory
	end
	
	it "specifies a display order for the subcategory within the category" do
		category_subcategory.should respond_to :subcategory_display_order
	end
end
