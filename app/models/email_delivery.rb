class EmailDelivery < ActiveRecord::Base
	has_paper_trail # Track changes to each email delivery record.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [:recipient, :sender, :email_type, :tracking_category]
	
	belongs_to :profile
	
	validates :recipient, email: true
	
	has_many :contact_blockers
	
	scope :order_by_descending_id, -> { order('id DESC') }
	
	# Generate a unique token.
	def self.generate_token
		UUIDTools::UUID.timestamp_create.to_s
	end
end
