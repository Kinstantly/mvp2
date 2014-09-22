class CreateCustomers < ActiveRecord::Migration
	def change
		create_table :customers do |t|
			t.integer :user_id

			t.timestamps
		end
		
		add_index :customers, :user_id
	end
end
