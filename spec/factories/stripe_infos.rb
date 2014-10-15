# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :stripe_info do
		stripe_user_id 'FactoryStripeUserId'
		access_token 'FactoryAccessToken'
		publishable_key 'FactoryPublishableKey'
	end
end
