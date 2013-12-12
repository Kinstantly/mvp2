class CacheRatingsCountAndReviewsCountInProfile < ActiveRecord::Migration
	def up
		execute "update profiles set ratings_count=(select count(*) from ratings where rateable_id=profiles.id and rateable_type='Profile')"
		execute "update profiles set reviews_count=(select count(*) from reviews where profile_id=profiles.id)"
	end

	def down
	end
end
