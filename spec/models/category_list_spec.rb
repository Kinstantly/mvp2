require 'spec_helper'

describe CategoryList, :type => :model do
	let(:category_list) { FactoryGirl.create :category_list }
	let(:first_category) { FactoryGirl.create(:category, name: 'Therapists') }
	let(:second_category) { FactoryGirl.create(:category, name: 'Tutors') }
	
	it "can have one category" do
		category_list.categories << first_category
		category_list.valid?
		expect(category_list.errors[:categories].size).to eq 0
		expect(category_list.categories.include?(first_category)).to be_truthy
	end
	
	it "can have many categories" do
		category_list.categories << first_category
		category_list.categories << second_category
		category_list.valid?
		expect(category_list.errors[:categories].size).to eq 0
		expect(category_list.categories.include?(first_category)).to be_truthy
		expect(category_list.categories.include?(second_category)).to be_truthy
	end
end
