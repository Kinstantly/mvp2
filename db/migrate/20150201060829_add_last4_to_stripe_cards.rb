class AddLast4ToStripeCards < ActiveRecord::Migration
	def change
		add_column :stripe_cards, :last4, :string
	end
end
