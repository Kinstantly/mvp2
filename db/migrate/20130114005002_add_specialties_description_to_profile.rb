class AddSpecialtiesDescriptionToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :specialties_description, :string
	end
end
