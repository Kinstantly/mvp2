class CreateCategoriesServices < ActiveRecord::Migration
	def change
		create_table :categories_services do |t|
			t.integer :category_id
			t.integer :service_id
		end
	end
end
