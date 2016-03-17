class CategoryList < ActiveRecord::Base
	has_paper_trail # Track changes to each category_list.
	
	has_and_belongs_to_many :categories, after_add: :categories_changed, after_remove: :categories_changed, join_table: 'categories_category_lists'
	
	ALL_LIST_NAME = 'all'
	HOME_LIST_NAME = 'home'
	
	def self.all_list
		self.where(name: ALL_LIST_NAME).first_or_create
	end
	
	def self.home_list
		self.where(name: HOME_LIST_NAME).first_or_create
	end
	
	private
	
	def categories_changed(category)
		touch
	end
end
