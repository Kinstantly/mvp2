class AddReviewerToReviews < ActiveRecord::Migration
	def change
		change_table :reviews do |t|
			t.belongs_to :reviewer
			t.index :reviewer_id
		end
	end
end
