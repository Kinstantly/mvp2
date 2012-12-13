# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :specialty do
		name "FactorySpecialty"
		
		factory :predefined_specialty do
			is_predefined true
		end
	end
end
