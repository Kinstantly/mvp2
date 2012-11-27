class AddIsPredefinedToCategory < ActiveRecord::Migration
	def change
		add_column :categories, :is_predefined, :boolean, default: false
	end
end
