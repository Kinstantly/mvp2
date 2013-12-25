require 'spec_helper'

describe CategoryList do
	let(:category_list) { FactoryGirl.create :category_list }
	let(:first_category) { FactoryGirl.create(:category, name: 'Therapists') }
	let(:second_category) { FactoryGirl.create(:category, name: 'Tutors') }
	
	it "can have one category" do
		category_list.categories << first_category
		category_list.should have(:no).errors_on(:categories)
		category_list.categories.include?(first_category).should be_true
	end
	
	it "can have many categories" do
		category_list.categories << first_category
		category_list.categories << second_category
		category_list.should have(:no).errors_on(:categories)
		category_list.categories.include?(first_category).should be_true
		category_list.categories.include?(second_category).should be_true
	end
end
