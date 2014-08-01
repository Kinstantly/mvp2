class EmailDelivery < ActiveRecord::Base
	attr_accessible :recipient, :sender, :email_type, :token, :tracking_category
	
	belongs_to :profile
end
