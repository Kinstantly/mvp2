class CreateCategorySubcategories < ActiveRecord::Migration
	def change
		create_table :categories_subcategories do |t|
			t.integer :category_id
			t.integer :subcategory_id
			t.integer :subcategory_display_order

			t.timestamps
		end

		add_index :categories_subcategories, :category_id
		add_index :categories_subcategories, :subcategory_id
	end
end
