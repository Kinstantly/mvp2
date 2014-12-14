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
				
				factory :refunded_stripe_charge_with_customer do
					customer_file
				end
			end
		
			factory :partially_refunded_stripe_charge do
				amount_refunded 50
				refunded false
				
				factory :partially_refunded_stripe_charge_with_customer do
					customer_file
				end
			end
		
			factory :captured_stripe_charge_with_customer do
				customer_file
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
		
		after(:create) do |stripe_charge|
			if not stripe_charge.stripe_card and stripe_charge.customer_file.try(:stripe_card)
				stripe_charge.stripe_card = stripe_charge.customer_file.stripe_card
				stripe_charge.save
			end
		end
	end
end
