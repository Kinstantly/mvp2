class AddProviderWantsToUser < ActiveRecord::Migration
	def change
		add_column :users, :wants_info_about_online_classes, :boolean, default: false
		add_column :users, :wants_to_be_interviewed, :boolean, default: false
	end
end
