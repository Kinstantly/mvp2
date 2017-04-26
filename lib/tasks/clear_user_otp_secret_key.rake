namespace :kinstantly do
	desc 'For each user that is NOT allowed to use two-factor authentication, clear out their one-time password secret key.'
	task clear_user_otp_secret_key: :environment do
		dry_run = ENV['dry_run'].present?
		
		puts 'Dry run!  No records will be saved.' if dry_run
		puts "email\t\troles\t\totp_secret_key"
		
		User.find_each do |user|
			unless user.two_factor_authentication_allowed?
				user.otp_secret_key = nil
				user.save! unless dry_run
				
				puts "#{user.email}\t#{user.roles}\t#{user.otp_secret_key}"
			end
		end
	end
end
