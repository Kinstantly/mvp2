class CreateCategoriesCategoryLists < ActiveRecord::Migration
	def change
		create_table :categories_category_lists, id: false do |t|
			t.integer :category_id
			t.integer :category_list_id
		end
		
		add_index :categories_category_lists, :category_id
		add_index :categories_category_lists, :category_list_id
	end
end
