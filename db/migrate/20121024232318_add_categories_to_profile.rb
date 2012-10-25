class AddCategoriesToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :categories, :text
  end
end
