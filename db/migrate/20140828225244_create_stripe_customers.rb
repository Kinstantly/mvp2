class CreateStripeCustomers < ActiveRecord::Migration
	def change
		create_table :stripe_customers do |t|
			t.integer :stripe_info_id
			t.string :api_customer_id
			t.string :description
			t.boolean :deleted, default: false

			t.timestamps
		end

		add_index :stripe_customers, :stripe_info_id
	end
end
