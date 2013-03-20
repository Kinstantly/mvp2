class CreateRatings < ActiveRecord::Migration
	def change
		create_table :ratings do |t|
			t.float :score, null: false
			t.belongs_to :rater
			t.belongs_to :rateable, polymorphic: true
			
			t.timestamps
		end
		
		add_index :ratings, :rater_id
		add_index :ratings, [:rateable_id, :rateable_type]
	end
end
