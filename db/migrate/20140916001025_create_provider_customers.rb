class CreateProviderCustomers < ActiveRecord::Migration
	def change
		create_table :provider_customers do |t|
			t.integer :user_id

			t.timestamps
		end
	end
end
