class AddTrashToCategoryServiceSpecialtyProfile < ActiveRecord::Migration
	def change
		add_column :categories, :trash, :boolean, default: false
		add_column :services, :trash, :boolean, default: false
		add_column :specialties, :trash, :boolean, default: false
		add_column :profiles, :trash, :boolean, default: false
	end
end
