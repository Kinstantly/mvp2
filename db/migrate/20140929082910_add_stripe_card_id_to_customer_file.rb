class AddStripeCardIdToCustomerFile < ActiveRecord::Migration
	def change
		add_column :customer_files, :stripe_card_id, :integer
		add_index :customer_files, :stripe_card_id
	end
end
