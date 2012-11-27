class CreateCategoriesSpecialties < ActiveRecord::Migration
	def change
		create_table :categories_specialties do |t|
			t.integer :category_id
			t.integer :specialty_id
		end
	end
end
