class Review < ActiveRecord::Base
	attr_accessible :body
	
	belongs_to :profile
end
