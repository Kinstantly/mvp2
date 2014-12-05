# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :stripe_charge do
		api_charge_id "FactoryApiChargeId"
		deleted false
		livemode true
		
		factory :captured_stripe_charge do
			amount 100
			paid true
			captured true
		
			factory :refunded_stripe_charge do
				amount_refunded 100
				refunded true
			end
		
			factory :partially_refunded_stripe_charge do
				amount_refunded 50
				refunded false
			end
		end
		
		factory :uncaptured_stripe_charge do
			amount 100
			paid true
			captured false
		end
		
		factory :stripe_charge_with_customer do
			customer_file
		end
	end
end
