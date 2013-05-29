class AddDisplayOrderToCategoryAndService < ActiveRecord::Migration
	def change
		add_column :categories, :display_order, :integer
		add_column :services, :display_order, :integer
	end
end
