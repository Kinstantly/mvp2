# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :category_subcategory do
		category
		subcategory
		subcategory_display_order 1
	end
end
