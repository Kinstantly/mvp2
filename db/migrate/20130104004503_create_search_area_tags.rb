class CreateSearchAreaTags < ActiveRecord::Migration
	def change
		create_table :search_area_tags do |t|
			t.string :name

			t.timestamps
		end
	end
end
