# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :customer do
		association :user, factory: :parent, email: 'ParentAsCustomer@example.com', username: 'ParentAsCustomer'
		
		factory :second_customer do
			association :user, factory: :parent, email: 'SecondParentAsCustomer@example.com', username: 'SecondParentAsCustomer'
		end
	end
end
