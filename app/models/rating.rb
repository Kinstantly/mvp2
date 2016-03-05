class Rating < ActiveRecord::Base
	# Remove the following after upgrading to Rails 4.0 or greater.
	include ActiveModel::ForbiddenAttributesProtection
	
	has_paper_trail # Track changes to each rating.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :score ]
	
	attr_protected :id # config.active_record.whitelist_attributes=true but we want it to be effectively false for selected models for which we want strong parameters to do the work.
	
	belongs_to :rater, class_name: 'User'
	belongs_to :rateable, polymorphic: true, counter_cache: true
	# belongs_to :review # when we had one rating per review.
	
	SCORES = 1..5
	
	validates :score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: SCORES.first, less_than_or_equal_to: SCORES.last }
	
	# Nice side effect: modifies the rateable which changes the cache_key for its fragment caches.
	after_save :update_profile_rating_score
	after_destroy :update_profile_rating_score
	
	private
	
	def update_profile_rating_score
		rateable.try(:update_rating_score)
	end
end
