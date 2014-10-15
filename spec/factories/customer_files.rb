# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :customer_file do
		association :provider, factory: :payable_provider
		association :customer, factory: :customer_with_card
		authorized_amount 1000
		
		factory :second_customer_file do
			association :provider, factory: :second_payable_provider
			association :customer, factory: :second_customer_with_card
		end
		
		after(:create) do |customer_file|
			customer_file.stripe_card = customer_file.customer.stripe_customer.stripe_cards.first
			customer_file.save
		end
	end
end
