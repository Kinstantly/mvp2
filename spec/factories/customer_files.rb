# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :customer_file do
		association :provider, factory: :provider
		association :customer, factory: :customer
		authorized_amount 1000
		
		factory :second_customer_file do
			association :provider, factory: :second_provider
			association :customer, factory: :second_customer
		end
	end
end
