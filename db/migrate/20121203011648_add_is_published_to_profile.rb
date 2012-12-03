class AddIsPublishedToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :is_published, :boolean, default: false
	end
end
