class CategorySubcategory < ActiveRecord::Base
	# Remove the following after upgrading to Rails 4.0 or greater.
	include ActiveModel::ForbiddenAttributesProtection
	
	def self.table_name
		'categories_subcategories'
	end
	
	# attr_accessible :category_id, :subcategory_id, :subcategory_display_order
	
	attr_protected :id # config.active_record.whitelist_attributes=true but we want it to be effectively false for selected models for which we want strong parameters to do the work.
	
	belongs_to :category, inverse_of: :category_subcategories
	belongs_to :subcategory, inverse_of: :category_subcategories
	
	after_save :notify_category
	
	private
	
	def notify_category
		category.subcategories_changed subcategory
	end
end
