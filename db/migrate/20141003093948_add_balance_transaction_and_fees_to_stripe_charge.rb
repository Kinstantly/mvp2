class AddBalanceTransactionAndFeesToStripeCharge < ActiveRecord::Migration
	def change
		add_column :stripe_charges, :balance_transaction, :string
		add_column :stripe_charges, :fee, :integer
		add_column :stripe_charges, :stripe_fee, :integer
		add_column :stripe_charges, :application_fee, :integer
		add_column :stripe_charges, :description, :string
		add_column :stripe_charges, :statement_description, :string
	end
end
