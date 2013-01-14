class DeviseUsersLockable < ActiveRecord::Migration
	# Devise Lockable module support.
	# Changes to users table needed to support lockouts on too many failed login attempts.
	
	def change
		change_table :users do |t|
			t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
			t.string   :unlock_token # Only if unlock strategy is :email or :both
			t.datetime :locked_at
		end
		
		add_index :users, :unlock_token, :unique => true
	end
end
