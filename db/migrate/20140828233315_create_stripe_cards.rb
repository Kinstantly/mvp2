class CreateStripeCards < ActiveRecord::Migration
	def change
		create_table :stripe_cards do |t|
			t.integer :stripe_customer_id
			t.string :api_card_id
			t.boolean :deleted, default: false

			t.timestamps
		end

		add_index :stripe_cards, :stripe_customer_id
	end
end
