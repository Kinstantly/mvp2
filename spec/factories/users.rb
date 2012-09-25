FactoryGirl.define do
	factory :profile do
		first_name 'Testy'
		last_name 'McUser'
	end
	
	factory :user do
		email 'example@example.com'
		password 'please'
		password_confirmation 'please'
		# required if the Devise Confirmable module is used
		# confirmed_at Time.now
		
		factory :user_with_profile do
			profile
		end
	end
end
