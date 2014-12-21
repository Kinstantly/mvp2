class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.integer :profile_id
      t.string :type
      t.integer :position
      t.integer :icon
      t.string :headline
      t.string :body
      t.string :button_or_link_text
      t.string :button_or_link_url
      t.date :date_start
      t.date :date_end
      t.boolean :active, default: false, null: false

      t.timestamps
    end
  end
end
