class Rating < ActiveRecord::Base
	attr_accessible :score
	
	belongs_to :rater, class_name: 'User'
	belongs_to :rateable, polymorphic: true
end
