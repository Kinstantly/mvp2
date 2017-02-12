class SubscriptionDelivery < ActiveRecord::Base
	has_paper_trail # Track changes to each subscription record.
	
	belongs_to :subscription
	belongs_to :subscription_stage
end
