class PopulateCategories < ActiveRecord::Migration
	@@categories = ['Parenting', 'Children\'s health', 'Money & Legal', 
		'Relationships', 'Specialty travel', 'Eldercare', 'Pet Care', 
		'Home Tech Support', 'College & Career Counseling', 'Medical', 
		'Self Care', 'other']
	
	class Category < ActiveRecord::Base
		# attr_accessible :name
	end
	
	def up
		Category.reset_column_information
		@@categories.each do |name|
			Category.create(name: name)
		end
	end

	def down
		Category.reset_column_information
		@@categories.each do |name|
			c = Category.find_by_name name
			c.destroy if c
		end
	end
end
