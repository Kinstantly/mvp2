class AddLastRefundedAtToStripeCharges < ActiveRecord::Migration
	def change
		add_column :stripe_charges, :last_refunded_at, :timestamp
	end
end
