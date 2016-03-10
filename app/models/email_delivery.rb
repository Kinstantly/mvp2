class EmailDelivery < ActiveRecord::Base
	# Remove the following after upgrading to Rails 4.0 or greater.
	include ActiveModel::ForbiddenAttributesProtection
	
	has_paper_trail # Track changes to each email delivery record.
	
	# attr_accessible :recipient, :sender, :email_type, :token, :tracking_category
	
	attr_protected :id # config.active_record.whitelist_attributes=true but we want it to be effectively false for selected models for which we want strong parameters to do the work.
	
	belongs_to :profile
	
	has_many :contact_blockers
end
