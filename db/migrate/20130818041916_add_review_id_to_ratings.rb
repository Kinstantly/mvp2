class AddReviewIdToRatings < ActiveRecord::Migration
	def change
		add_column :ratings, :review_id, :integer
		add_index :ratings, :review_id
	end
end
