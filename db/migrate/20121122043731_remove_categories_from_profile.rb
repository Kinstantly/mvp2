class RemoveCategoriesFromProfile < ActiveRecord::Migration
	def up
		remove_column :profiles, :subcategory, :category_id, :categories
	end
	
	def down
		add_column :profiles, :categories, :text
		add_column :profiles, :category_id, :integer
		add_column :profiles, :subcategory, :string
	end
end
