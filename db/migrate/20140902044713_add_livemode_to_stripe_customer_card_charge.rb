class AddLivemodeToStripeCustomerCardCharge < ActiveRecord::Migration
	def change
		add_column :stripe_customers, :livemode, :boolean
		add_column :stripe_cards, :livemode, :boolean
		add_column :stripe_charges, :livemode, :boolean
	end
end
