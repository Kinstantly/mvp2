class AddPhotoSourceUrlToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :photo_source_url, :string
	end
end
