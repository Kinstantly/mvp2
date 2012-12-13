# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :service do
		name "FactoryService"
		
		factory :predefined_service do
			is_predefined true
		end
	end
end
