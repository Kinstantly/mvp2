class CategoryProfile < ActiveRecord::Base
	def self.table_name
		'categories_profiles'
	end
	
	belongs_to :category
	belongs_to :profile
end
