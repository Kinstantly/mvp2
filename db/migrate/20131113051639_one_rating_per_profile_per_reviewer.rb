class OneRatingPerProfilePerReviewer < ActiveRecord::Migration
	
	class User < ActiveRecord::Base
	end
	
	class Profile < ActiveRecord::Base
		has_many :reviews
	end
	
	class Review < ActiveRecord::Base
		belongs_to :profile
		belongs_to :reviewer, class_name: 'User'
		has_one :rating
	end
	
	class Rating < ActiveRecord::Base
		belongs_to :rateable, polymorphic: true
		belongs_to :rater, class_name: 'User'
	end
	
	def setup
		User.reset_column_information
		Profile.reset_column_information
		Review.reset_column_information
		Rating.reset_column_information
	end
	
	def up
		setup
		Review.all.each do |review|
			profile = review.profile
			reviewer = review.reviewer
			rating = profile.reviews.where(reviewer_id: reviewer.id).sort{ |a, b|
				a.rating.score <=> b.rating.score
			}.last.rating
			rating.rateable = profile
			rating.rateable_type = 'Profile' # Otherwise we get 'OneRatingPerProfilePerReviewer::Profile'!
			rating.rater = reviewer
			rating.save!
		end
	end
	
	def down
		setup
		Rating.all.each do |rating|
			rating.rateable = nil
			rating.rater = nil
			rating.save!
		end
	end
end
