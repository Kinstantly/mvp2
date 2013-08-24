class ConvertRatingScoreToInteger < ActiveRecord::Migration
	def up
		change_table :ratings do |t|
			t.remove :score
			t.integer :score, null: false
		end
	end

	def down
		change_table :ratings do |t|
			t.remove :score
			t.float :score, null: false
		end
	end
end
