FactoryGirl.define do
	factory :user do
		transient do
			require_confirmation false
			require_two_factor_authentication false
			pending_welcome false
		end
		
		email 'FactoryEmail@kinstantly.com'
		password 'FactoryPassword'
		password_confirmation 'FactoryPassword'
		profile_help false
		
		after(:build) { |user, evaluator|
			# In case we are using the Devise Confirmable module, do not require the confirmation step
			# unless otherwise specified.
			# Do it here because confirmed_at cannot be mass assigned.
			user.skip_confirmation! unless evaluator.require_confirmation
		}
		
		after(:create) { |user, evaluator|
			# two_factor_authentication automatically sets up a otp_secret_key which then requires doing
			# the two-factor authentication step during sign-ins.  We don't want to mess with that for most tests.
			# So don't require two-factor authentication unless so specified.
			unless evaluator.require_two_factor_authentication
				user.otp_secret_key = nil
				user.save
			end
		}
		
		profile
		
		factory :user_with_no_email do
			email ''
		end
		
		factory :expert_user, aliases: [:provider, :provider_with_no_username] do
			email 'FactoryEmailProvider@kinstantly.com'
			roles [:expert]
		
			# Assume the user has received the welcome email unless otherwise specified.
			# Do it here because welcome_sent_at cannot be mass assigned.
			after(:build) { |user, evaluator| user.welcome_sent_at = Time.at(0).utc unless evaluator.pending_welcome }
			
			factory :second_provider do
				email 'FactoryEmailSecondProvider@example.com'
			end
			
			factory :provider_with_username do
				username 'FactoryUsernameProvider'
			end
			
			factory :provider_with_published_profile do
				association :profile, factory: :published_profile
			end
			
			factory :provider_with_unpublished_profile do
				association :profile, factory: :unpublished_profile
			end
			
			factory :payable_provider do
				stripe_info
				association :profile, factory: :profile_allowed_charge_authorizations
				
				factory :second_payable_provider do
					email 'FactoryEmailSecondPayableProvider@example.com'
				end
			end
			
			factory :provider_before_payment_setup do
				association :profile, factory: :profile_showing_stripe_connect
			end
		end
		
		factory :admin_user do
			email 'FactoryEmailAdmin@kinstantly.com'
			roles [:admin]
		end
		
		factory :profile_editor do
			email 'FactoryEmailProfileEditor@kinstantly.com'
			roles [:profile_editor]
		end
		
		# Let's have a typical reviewer be a parent (even though it could be a provider).
		factory :client_user, aliases: [:parent, :reviewer] do
			email 'FactoryEmailParent@kinstantly.com'
			roles [:client]
			username 'FactoryUsernameParent'
			profile nil
			
			factory :second_parent do
				email 'FactoryEmailSecondParent@kinstantly.com'
				username 'FactoryUsernameSecondParent'
			end
		end
	end
end
