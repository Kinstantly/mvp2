class AddListIdToSubscriptionStage < ActiveRecord::Migration
	def change
		add_column :subscription_stages, :list_id, :string
		add_index :subscription_stages, :list_id
	end
end
