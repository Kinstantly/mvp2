FactoryGirl.define do
	factory :user do
		ignore do
			require_confirmation false
			pending_welcome false
		end
		
		email 'FactoryEmail@example.com'
		password 'FactoryPassword'
		password_confirmation 'FactoryPassword'
		
		# In case we are using the Devise Confirmable module, do not require the confirmation step
		# unless otherwise specified.
		# Do it here because confirmed_at cannot be mass assigned.
		after(:build) { |user, evaluator| user.skip_confirmation! unless evaluator.require_confirmation }
		
		profile
		
		factory :user_with_no_email do
			email ''
		end
		
		factory :expert_user, aliases: [:provider, :provider_with_no_username] do
			email 'FactoryEmailProvider@example.com'
			roles [:expert]
		
			# Assume the user has received the welcome email unless otherwise specified.
			# Do it here because welcome_sent_at cannot be mass assigned.
			after(:build) { |user, evaluator| user.welcome_sent_at = Time.at(0).utc unless evaluator.pending_welcome }
			
			factory :provider_with_username do
				username 'FactoryUsernameProvider'
			end
		end
		
		factory :admin_user do
			email 'FactoryEmailAdmin@example.com'
			roles [:admin]
		end
		
		factory :profile_editor do
			email 'FactoryEmailProfileEditor@example.com'
			roles [:profile_editor]
		end
		
		# Let's have a typical reviewer be a parent (even though it could be a provider).
		factory :client_user, aliases: [:parent, :reviewer] do
			email 'FactoryEmailParent@example.com'
			roles [:client]
			username 'FactoryUsernameParent'
			
			factory :second_parent do
				email 'FactoryEmailSecondParent@example.com'
				username 'FactoryUsernameSecondParent'
			end
		end
	end
end
