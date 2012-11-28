class AddIsPredefinedToSpecialty < ActiveRecord::Migration
	def change
		add_column :specialties, :is_predefined, :boolean, default: false
	end
end
