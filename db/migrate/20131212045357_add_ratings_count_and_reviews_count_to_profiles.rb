class AddRatingsCountAndReviewsCountToProfiles < ActiveRecord::Migration
	def change
		add_column :profiles, :ratings_count, :integer, default: 0, null: false
		add_column :profiles, :reviews_count, :integer, default: 0, null: false
	end
end
