# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :email_delivery do
		recipient 'FactoryRecipient@example.org'
		sender 'FactorySender'
		email_type 'FactoryEmailType'
		tracking_category 'FactoryTrackingCategory'
	end
end
