# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :customer do
		association :user, factory: :second_parent
	end
end
