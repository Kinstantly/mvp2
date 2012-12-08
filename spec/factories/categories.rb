# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :category do
		name 'FactoryCategory'
		
		factory :predefined_category do
			is_predefined true
		end
	end
end
