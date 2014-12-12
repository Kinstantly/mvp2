class AddFeeRefundedEtAlToStripeCharges < ActiveRecord::Migration
	def change
		add_column :stripe_charges, :fee_refunded, :integer
		add_column :stripe_charges, :stripe_fee_refunded, :integer
		add_column :stripe_charges, :application_fee_refunded, :integer
	end
end
