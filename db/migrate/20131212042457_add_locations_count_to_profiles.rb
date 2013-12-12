class AddLocationsCountToProfiles < ActiveRecord::Migration
	def change
		add_column :profiles, :locations_count, :integer, default: 0, null: false
	end
end
