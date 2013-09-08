class AddHomePageColumnAndSeeAllColumnToCategory < ActiveRecord::Migration
	def change
		add_column :categories, :home_page_column, :integer
		add_column :categories, :see_all_column, :integer, default: 1
	end
end
