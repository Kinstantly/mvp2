class EmailDelivery < ActiveRecord::Base
	has_paper_trail # Track changes to each email delivery record.
	
	# attr_accessible :recipient, :sender, :email_type, :token, :tracking_category
	
	belongs_to :profile
	
	has_many :contact_blockers
end
