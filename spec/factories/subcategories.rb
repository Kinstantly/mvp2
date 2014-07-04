# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :subcategory, aliases: [:subcategory_not_on_home_page] do
		name "FactorySubcategory"
	
		factory :subcategory_on_home_page do
			after(:create) do |subcategory, evaluator|
				subcategory.categories = create_list(:category_on_home_page, 1)
			end
		end
	end
end
