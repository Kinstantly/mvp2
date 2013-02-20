class AddAdminNotesToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :admin_notes, :text
  end
end
