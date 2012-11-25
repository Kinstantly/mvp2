class CreateCategoriesProfiles < ActiveRecord::Migration
	def change
		create_table :categories_profiles do |t|
			t.integer :category_id
			t.integer :profile_id
		end
	end
end
