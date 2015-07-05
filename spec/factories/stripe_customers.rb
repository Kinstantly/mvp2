# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :stripe_customer do
		api_customer_id "FactoryApiCustomerId"
		description 'FactoryDescription'
		deleted false
		livemode true
		
		factory :stripe_customer_with_cards do
			transient do
				card_count 1
			end

			after(:create) do |stripe_customer, evaluator|
				create_list(:stripe_card, evaluator.card_count, stripe_customer: stripe_customer)
			end
		end
	end
end
