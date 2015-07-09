# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :email_delivery do
		recipient 'FactoryRecipient@example.org'
		sender 'FactorySender'
		email_type 'FactoryEmailType'
		token 'FactoryToken'
		tracking_category 'FactoryTrackingCategory'
		
		factory :email_delivery_with_contact_blockers do
			transient do
				contact_blockers_count 1
			end
			
			after(:create) do |email_delivery, evaluator|
				create_list(:contact_blocker, evaluator.contact_blockers_count, email_delivery: email_delivery)
			end
		end
	end
end
