class ProfilesSubcategories < ActiveRecord::Migration
	def change
		create_table :profiles_subcategories do |t|
			t.integer :profile_id
			t.integer :subcategory_id
		end

		add_index :profiles_subcategories, :profile_id
		add_index :profiles_subcategories, :subcategory_id
	end
end
