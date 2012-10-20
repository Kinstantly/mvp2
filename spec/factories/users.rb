FactoryGirl.define do
	factory :user do
		email 'example@example.com'
		password 'please'
		password_confirmation 'please'
		# required if the Devise Confirmable module is used
		# confirmed_at Time.now
		
		profile
		
		factory :user_with_no_email do
			email ''
		end
		
		factory :admin_user do
			roles [:admin]
		end
	end
end
