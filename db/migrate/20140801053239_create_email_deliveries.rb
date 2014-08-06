class CreateEmailDeliveries < ActiveRecord::Migration
	def change
		create_table :email_deliveries do |t|
			t.string :recipient
			t.string :sender
			t.string :email_type
			t.string :token
			t.string :tracking_category
			t.integer :profile_id

			t.timestamps
		end
		
		add_index :email_deliveries, :token
		add_index :email_deliveries, :profile_id
	end
end
