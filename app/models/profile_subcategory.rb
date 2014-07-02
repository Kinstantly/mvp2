class ProfileSubcategory < ActiveRecord::Base
	def self.table_name
		'profiles_subcategories'
	end
	
	belongs_to :subcategory
	belongs_to :profile
end
