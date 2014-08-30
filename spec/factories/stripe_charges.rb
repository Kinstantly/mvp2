# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :stripe_charge do
		api_charge_id "FactoryApiChargeId"
	end
end
