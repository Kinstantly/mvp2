class AddProviderCustomerIdToStripeCustomer < ActiveRecord::Migration
	def change
		add_column :stripe_customers, :provider_customer_id, :integer

		add_index :stripe_customers, :provider_customer_id
	end
end
