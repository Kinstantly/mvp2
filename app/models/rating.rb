class Rating < ActiveRecord::Base
	has_paper_trail # Track changes to each rating.
	
	attr_accessible :score
	
	belongs_to :rater, class_name: 'User'
	belongs_to :rateable, polymorphic: true, counter_cache: true
	# belongs_to :review # when we had one rating per review.
	
	SCORES = 1..5
	
	validates :score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: SCORES.first, less_than_or_equal_to: SCORES.last }
	
	after_save :update_profile_rating_score
	after_destroy :update_profile_rating_score
	
	private
	
	def update_profile_rating_score
		rateable.try(:update_rating_score)
	end
end
