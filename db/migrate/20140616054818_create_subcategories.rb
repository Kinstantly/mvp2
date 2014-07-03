class CreateSubcategories < ActiveRecord::Migration
	def change
		create_table :subcategories do |t|
			t.string :name
			t.boolean :trash, default: false

			t.timestamps
		end
	end
end
