class AddCategoryToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :category_id, :integer
  end
end
