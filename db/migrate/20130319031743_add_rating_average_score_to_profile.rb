class AddRatingAverageScoreToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :rating_average_score, :float
	end
end
