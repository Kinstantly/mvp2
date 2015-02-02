# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :stripe_card, aliases: [:stripe_card_with_no_customer] do
		api_card_id "FactoryApiCardId"
		deleted false
		livemode true
		brand 'FactoryBrand'
		funding 'FactoryFunding'
		last4 '1234'
		
		after(:build) do |stripe_card|
			exp_date = Time.zone.now + 1.year
			stripe_card.exp_month = exp_date.month
			stripe_card.exp_year = exp_date.year
		end
	end
end
