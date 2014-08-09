require 'spec_helper'

describe "home/index" do
	it "shows the home page categories" do
		['Activities', 'Education', 'Family Services', 'Health', 'Therapy & Coaching'].each do |name|
			FactoryGirl.create :predefined_category, name: name
		end
		render
		CategoryList.home_list.categories.each do |category|
			rendered.should have_content(category.name)
		end
	end
end
