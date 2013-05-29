# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :category do
		name 'FactoryCategory'
		
		factory :predefined_category do
			is_predefined true
		end
		
		factory :category_on_home_page do
			is_predefined true
			display_order 1
		end
	end
end
