class CreateServiceSubcategories < ActiveRecord::Migration
	def change
		create_table :services_subcategories do |t|
			t.integer :service_id
			t.integer :subcategory_id
			t.integer :service_display_order

			t.timestamps
		end

		add_index :services_subcategories, :service_id
		add_index :services_subcategories, :subcategory_id
	end
end
