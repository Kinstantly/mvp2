# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :service do
		name "FactoryService"
		
		factory :predefined_service, aliases: [:service_not_on_home_page] do
			is_predefined true
			
			factory :service_on_home_page do
				after(:create) do |service, evaluator|
					service.subcategories = create_list(:subcategory_on_home_page, 1)
				end
			end
		end
	end
end
