class RemoveCropPropertiesFromProfile < ActiveRecord::Migration
  def up
		remove_column :profiles, :profile_photo_crop_top
		remove_column :profiles, :profile_photo_crop_right
		remove_column :profiles, :profile_photo_crop_bottom
		remove_column :profiles, :profile_photo_crop_left
  end

  def down
		change_table :profiles do |t|
			t.integer :profile_photo_crop_top
			t.integer :profile_photo_crop_right
			t.integer :profile_photo_crop_bottom
			t.integer :profile_photo_crop_left
		end
  end
end
