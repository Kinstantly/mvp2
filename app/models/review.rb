class Review < ActiveRecord::Base
	attr_accessible :body
	
	belongs_to :profile
	
	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MAX_LENGTHS = {
		body: 1000
	}
	
	validates :body, length: {maximum: MAX_LENGTHS[:body]}
end
