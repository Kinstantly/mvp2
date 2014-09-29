class AddCustomerFileIdToStripeCharge < ActiveRecord::Migration
	def change
		add_column :stripe_charges, :customer_file_id, :integer
		add_index :stripe_charges, :customer_file_id
	end
end
