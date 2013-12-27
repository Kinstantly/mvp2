class SetUpCategoryLists < ActiveRecord::Migration
	
	ALL_LIST_NAME = 'all'
	HOME_LIST_NAME = 'home'
	
	class CategoryList < ActiveRecord::Base
		has_and_belongs_to_many :categories
	end
	
	class Category < ActiveRecord::Base
		has_and_belongs_to_many :category_lists
	end
	
	def up
		CategoryList.reset_column_information
		Category.reset_column_information
		all_list = CategoryList.where(name: ALL_LIST_NAME).first_or_create
		home_list = CategoryList.where(name: HOME_LIST_NAME).first_or_create
		all_list.categories = []
		home_list.categories = []
		Category.where(is_predefined: true).each do |category|
			all_list.categories << category
			home_list.categories << category if category.home_page_column
		end
	end

	def down
	end
end
