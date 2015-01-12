class AddAnnouncementsCountToProfiles < ActiveRecord::Migration
  def change
  	add_column :profiles, :announcements_count, :integer, default: 0, null: false
  end
end
