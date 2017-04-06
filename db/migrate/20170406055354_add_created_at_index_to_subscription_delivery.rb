class AddCreatedAtIndexToSubscriptionDelivery < ActiveRecord::Migration
	def change
		add_index :subscription_deliveries, :created_at
	end
end
