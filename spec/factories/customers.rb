# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :customer do
		association :user, factory: :parent, email: 'ParentAsCustomer@example.com', username: 'ParentAsCustomer'
		
		factory :customer_with_card do
			association :stripe_customer, factory: :stripe_customer_with_cards, card_count: 1
		end
		
		factory :second_customer do
			association :user, factory: :parent, email: 'SecondParentAsCustomer@example.com', username: 'SecondParentAsCustomer'
		
			factory :second_customer_with_card do
				association :stripe_customer, factory: :stripe_customer_with_cards, card_count: 1
			end
		end
	end
end
