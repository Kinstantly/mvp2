FactoryGirl.define do
	factory :user do
		email 'example@example.com'
		password 'please'
		password_confirmation 'please'
		
		# confirmed_at is required if the Devise Confirmable module is used.
		# However, confirmed_at cannot be mass assigned, so ensure it is not returned by attributes_for().
		after(:build) { |user| user.confirmed_at = Time.now }
		
		profile
		
		factory :user_with_no_email do
			email ''
		end
		
		factory :expert_user do
			roles [:expert]
		end
		
		factory :admin_user do
			roles [:admin]
		end
		
		factory :profile_editor do
			roles [:profile_editor]
		end
		
		factory :client_user do
			roles [:client]
			username 'example_username'
		end
	end
end
