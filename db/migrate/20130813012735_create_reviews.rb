class CreateReviews < ActiveRecord::Migration
	def change
		create_table :reviews do |t|
			t.integer :profile_id
			t.text :body

			t.timestamps
		end
	end
end
