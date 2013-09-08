# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :service do
		name "FactoryService"
		
		factory :predefined_service do
			is_predefined true
			
			factory :service_on_home_page do
				show_on_home_page true
			end
			
			factory :service_not_on_home_page do
				show_on_home_page false
			end
		end
	end
end
