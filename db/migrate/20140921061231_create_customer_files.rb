class CreateCustomerFiles < ActiveRecord::Migration
	def change
		create_table :customer_files do |t|
			t.integer :customer_id
			t.integer :user_id # references the provider which is in the users table
			t.integer :authorization_amount

			t.timestamps
		end

		add_index :customer_files, :customer_id
		add_index :customer_files, :user_id
	end
end
