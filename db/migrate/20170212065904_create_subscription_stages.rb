class CreateSubscriptionStages < ActiveRecord::Migration
	def change
		create_table :subscription_stages do |t|
			t.string :title
			t.string :source_campaign_id
			t.integer :trigger_delay_days

			t.timestamps null: false
		end
	end
end
