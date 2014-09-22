class CustomerFile < ActiveRecord::Base
	has_paper_trail # Track changes to each customer file.
	
	belongs_to :provider, class_name: 'User', foreign_key: 'user_id'
	belongs_to :customer
end
