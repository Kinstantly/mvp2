class AddBrandFundingExpirationToStripeCard < ActiveRecord::Migration
	def change
		add_column :stripe_cards, :brand, :string
		add_column :stripe_cards, :funding, :string
		add_column :stripe_cards, :exp_month, :integer
		add_column :stripe_cards, :exp_year, :integer
	end
end
