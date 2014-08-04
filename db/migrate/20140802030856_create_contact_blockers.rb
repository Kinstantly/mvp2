class CreateContactBlockers < ActiveRecord::Migration
	def change
		create_table :contact_blockers do |t|
			t.string :email
			t.integer :email_delivery_id

			t.timestamps
		end
		
		add_index :contact_blockers, :email_delivery_id
	end
end
