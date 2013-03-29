class DropCategoriesSpecialties < ActiveRecord::Migration
	def up
		drop_table :categories_specialties
	end

	def down
	end
end
