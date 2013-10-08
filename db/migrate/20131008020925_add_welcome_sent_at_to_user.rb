class AddWelcomeSentAtToUser < ActiveRecord::Migration
	class User < ActiveRecord::Base
	end
	
	def up
		add_column :users, :welcome_sent_at, :datetime
		
		# Mark all existing users as having received the welcome email even though it didn't exist until now.
		# We don't want to inadvertantly send them new welcome emails, e.g., when confirming an email address change.
		User.reset_column_information
		User.all.each do |user|
			# Set to the epoch to signify that it's just a marker.
			user.update_attribute :welcome_sent_at, Time.at(0).utc
		end
	end
	
	def down
		remove_column :users, :welcome_sent_at
	end
end
