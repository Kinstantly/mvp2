class AddScheduleTimeToSubscriptionDelivery < ActiveRecord::Migration
	def change
		add_column :subscription_deliveries, :schedule_time, :datetime
	end
end
