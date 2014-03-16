class AddAdminConfirmationSentAttributesToUsers < ActiveRecord::Migration
	def change
		add_column :users, :admin_confirmation_sent_at, :datetime
		add_column :users, :admin_confirmation_sent_by_id, :integer
	end
end
