class AddServiceAreaToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :service_area, :text
	end
end
