RSpec.configure do |config|
	config.include Devise::TestHelpers, :type => :controller
	config.include Devise::TestHelpers, :type => :view
end

def devise_raw_confirmation_token(user)
	raw_token, encoded_token = Devise.token_generator.generate(user.class, :confirmation_token)
	user.confirmation_token = encoded_token
	user.confirmation_sent_at = Time.now.utc
	user.save
	raw_token
end

def devise_raw_reset_password_token(user)
	raw_token, encoded_token = Devise.token_generator.generate(user.class, :reset_password_token)
	user.reset_password_token = encoded_token
	user.reset_password_sent_at = Time.now.utc
	user.save
	raw_token
end
