class CreateCategoryLists < ActiveRecord::Migration
	def change
		create_table :category_lists do |t|
			t.string :name

			t.timestamps
		end
	end
end
