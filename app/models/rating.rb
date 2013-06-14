class Rating < ActiveRecord::Base
	has_paper_trail # Track changes to each rating.
	
	attr_accessible :score
	
	belongs_to :rater, class_name: 'User'
	belongs_to :rateable, polymorphic: true
end
