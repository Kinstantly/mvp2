class AddResourcesToProfiles < ActiveRecord::Migration
	def change
		add_column :profiles, :resources, :text
	end
end
