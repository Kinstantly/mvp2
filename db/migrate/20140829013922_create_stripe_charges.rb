class CreateStripeCharges < ActiveRecord::Migration
	def change
		create_table :stripe_charges do |t|
			t.integer :stripe_card_id
			t.string :api_charge_id
			t.integer :amount
			t.integer :amount_refunded
			t.boolean :paid, default: false
			t.boolean :refunded, default: false
			t.boolean :captured, default: false
			t.boolean :deleted, default: false

			t.timestamps
		end

		add_index :stripe_charges, :stripe_card_id
	end
end
