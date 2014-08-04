# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :contact_blocker do
		email "FactoryEmail@example.org"
		
		factory :contact_blocker_with_email_delivery do
			association :email_delivery, recipient: "FactoryEmail@example.org"
		end
	end
end
