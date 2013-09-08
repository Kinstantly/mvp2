class AddShowOnHomePageToService < ActiveRecord::Migration
	def change
		add_column :services, :show_on_home_page, :boolean
	end
end
