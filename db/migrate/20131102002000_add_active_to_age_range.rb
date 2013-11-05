class AddActiveToAgeRange < ActiveRecord::Migration
	def change
		add_column :age_ranges, :active, :boolean, default: false
	end
end
