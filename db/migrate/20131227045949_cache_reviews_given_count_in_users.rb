class CacheReviewsGivenCountInUsers < ActiveRecord::Migration
	def up
		execute 'update users set reviews_given_count=(select count(*) from reviews where reviewer_id=users.id)'
	end

	def down
	end
end
