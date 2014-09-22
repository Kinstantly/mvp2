class AddCustomerIdToStripeCustomer < ActiveRecord::Migration
	def change
		add_column :stripe_customers, :customer_id, :integer

		add_index :stripe_customers, :customer_id
	end
end
