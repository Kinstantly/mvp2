# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :customer_file do
		association :provider, factory: :payable_provider
		association :customer, factory: :customer_with_card
		authorized_amount 1000
		
		ignore do
			authorized_amount_usd nil
		end
		
		after(:build) do |customer_file, evaluator|
			customer_file.authorized_amount_usd = evaluator.authorized_amount_usd if evaluator.authorized_amount_usd.present?
		end
		
		after(:create) do |customer_file|
			customer_file.stripe_card = customer_file.customer.stripe_customer.stripe_cards.first
			customer_file.save
		end
		
		factory :second_customer_file do
			association :provider, factory: :second_payable_provider
			association :customer, factory: :second_customer_with_card
		end
	end
end
