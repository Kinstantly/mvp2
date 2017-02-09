class Subscription < ActiveRecord::Base
	has_paper_trail # Track changes to each subscription record.
	
	before_save :sync_subscribed_status
	
	private
	
	# The subscribed property is an indexed boolean to be used for efficient lookups.
	# Make sure it's in sync with the status property.
	def sync_subscribed_status
		self.subscribed = self.status == 'subscribed'
		true # Ensure the execution chain continues.
	end
end
