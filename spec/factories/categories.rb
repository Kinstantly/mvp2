# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :category do
		name 'FactoryCategory'
		
		factory :predefined_category do
			is_predefined true
			# see_all_column 1 # required if predefined
		
			factory :category_on_home_page do
				home_page_column 1
			end
		
			factory :category_not_on_home_page do
				home_page_column nil
			end
		end
	end
end
