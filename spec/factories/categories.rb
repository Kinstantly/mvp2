# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :category do
		name 'MyString'
		
		factory :predefined_category do
			is_predefined true
		end
	end
end
