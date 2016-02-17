namespace :kinstantly do
	desc 'For each user that is allowed to use two-factor authentication and does not already have a one-time password secret key, create one for them.'
	task create_user_otp_secret_key: :environment do
		dry_run = ENV['dry_run'].present?
		
		puts 'Dry run!  No records will be saved.' if dry_run
		puts "email\t\troles\t\totp_secret_key"
		
		User.all.each do |user|
			if user.two_factor_authentication_allowed? and user.otp_secret_key.blank?
				user.reset_otp_secret_key
				user.save! unless dry_run
				
				puts "#{user.email}\t#{user.roles}\t#{user.otp_secret_key}"
			end
		end
	end
end
