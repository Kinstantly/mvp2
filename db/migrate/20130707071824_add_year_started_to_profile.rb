class AddYearStartedToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :year_started, :string
	end
end
