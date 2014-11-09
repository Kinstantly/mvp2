# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :stripe_card, aliases: [:stripe_card_with_no_customer] do
		api_card_id "FactoryApiCardId"
		deleted false
		livemode true
	end
end
