# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :age_range do
		name "preconception"
		sort_index 1
		active true
		
		factory :retired_age_range do
			active false
		end
	end
end
