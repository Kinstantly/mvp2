class AddAttachmentProfilePhotoToProfiles < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.attachment :profile_photo
      t.integer :profile_photo_crop_top
      t.integer :profile_photo_crop_right
      t.integer :profile_photo_crop_bottom
      t.integer :profile_photo_crop_left
    end
  end

  def self.down
    drop_attached_file :profiles, :profile_photo
    remove_column :profiles, :profile_photo_crop_top
    remove_column :profiles, :profile_photo_crop_right
    remove_column :profiles, :profile_photo_crop_bottom
    remove_column :profiles, :profile_photo_crop_left
  end
end
