# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :stripe_customer do
		api_customer_id "FactoryApiCustomerId"
	end
end