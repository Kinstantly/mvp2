class Subscription < ActiveRecord::Base
	has_paper_trail # Track changes to each subscription record.
	
	before_save :sync_subscribed_status
	
	# Class method to find the matching subscription while ignoring the case of the email address.
	def self.find_by_lower_email_and_list_id(email, list_id)
		where(list_id: list_id).where('LOWER(email) = ?', email.strip.downcase).take
	end
	
	private
	
	# The subscribed property is an indexed boolean to be used for efficient lookups.
	# Make sure it's in sync with the status property.
	def sync_subscribed_status
		self.subscribed = self.status == 'subscribed'
		true # Ensure the execution chain continues.
	end
end
