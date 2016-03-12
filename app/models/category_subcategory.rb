class CategorySubcategory < ActiveRecord::Base
	def self.table_name
		'categories_subcategories'
	end
	
	# attr_accessible :category_id, :subcategory_id, :subcategory_display_order
	
	belongs_to :category, inverse_of: :category_subcategories
	belongs_to :subcategory, inverse_of: :category_subcategories
	
	after_save :notify_category
	
	private
	
	def notify_category
		category.subcategories_changed subcategory
	end
end
