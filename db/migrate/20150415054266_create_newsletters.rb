class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string :cid
      t.string :list_id
      t.string :title
      t.string :subject
      t.string :archive_url
      t.text :content
      t.date :send_time

      t.timestamps
    end
  end
end
