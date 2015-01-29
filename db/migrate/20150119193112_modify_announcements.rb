class ModifyAnnouncements < ActiveRecord::Migration
   def change
    rename_column :announcements, :date_start, :start_at
    rename_column :announcements, :date_end, :end_at
    change_column :announcements, :start_at, :timestamp
    change_column :announcements, :end_at, :timestamp
    change_column :announcements, :body, :text
    rename_column :announcements, :button_or_link_text, :button_text
    rename_column :announcements, :button_or_link_url, :button_url
    add_column :announcements, :search_result_position, :integer, after: :button_url
    add_column :announcements, :search_result_link_text, :string, after: :search_result_position
  end
end
