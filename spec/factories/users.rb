FactoryGirl.define do
	factory :user do
		ignore do
			require_confirmation false
		end
		
		email 'example@example.com'
		password 'please'
		password_confirmation 'please'
		
		# In case we are using the Devise Confirmable module, do not require the confirmation step
		# unless otherwise specified.
		# Do it here because confirmed_at cannot be mass assigned.
		after(:build) { |user, evaluator| user.skip_confirmation! unless evaluator.require_confirmation }
		
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
