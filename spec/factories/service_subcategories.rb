# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :service_subcategory do
		service
		subcategory
		service_display_order 1
	end
end
