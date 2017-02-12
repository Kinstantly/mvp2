class CreateSubscriptionDeliveries < ActiveRecord::Migration
	def change
		create_table :subscription_deliveries do |t|
			t.references :subscription, index: true, foreign_key: true
			t.references :subscription_stage, index: true, foreign_key: true
			t.string :email
			t.string :source_campaign_id
			t.string :campaign_id
			t.datetime :send_time

			t.timestamps null: false
		end
	end
end
