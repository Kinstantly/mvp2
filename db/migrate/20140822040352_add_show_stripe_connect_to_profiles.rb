class AddShowStripeConnectToProfiles < ActiveRecord::Migration
	def change
		add_column :profiles, :show_stripe_connect, :boolean, default: false
	end
end
