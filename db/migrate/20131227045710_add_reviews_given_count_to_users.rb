class AddReviewsGivenCountToUsers < ActiveRecord::Migration
	def change
		add_column :users, :reviews_given_count, :integer, default: 0, null: false
	end
end
