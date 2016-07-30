class EmailDelivery < ActiveRecord::Base
	has_paper_trail # Track changes to each email delivery record.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [:recipient, :sender, :email_type, :tracking_category]
	
	belongs_to :profile
	
	validates :recipient, email: true
	
	has_many :contact_blockers
end
