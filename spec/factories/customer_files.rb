# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :customer_file do
		association :provider, factory: :provider
		association :customer, factory: :customer
		authorization_amount 1000
	end
end
