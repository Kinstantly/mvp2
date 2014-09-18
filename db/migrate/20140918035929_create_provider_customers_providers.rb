class CreateProviderCustomersProviders < ActiveRecord::Migration
	def change
		create_table :provider_customers_providers do |t|
			t.integer :provider_customer_id
			t.integer :user_id # providers are in the users table
		end

		add_index :provider_customers_providers, :provider_customer_id
		add_index :provider_customers_providers, :user_id
	end
end
