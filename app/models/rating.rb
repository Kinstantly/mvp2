class Rating < ActiveRecord::Base
	has_paper_trail # Track changes to each rating.
	
	attr_accessible :score
	
	belongs_to :review
	
	validates :score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
	
	SCORES = 1..5
	
	after_save :update_profile_rating_score
	after_destroy :update_profile_rating_score
	
	private
	
	def update_profile_rating_score
		review.try(:profile).try(:update_rating_score)
	end
end
