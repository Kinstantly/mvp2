class AddSearchAreaTagToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :search_area_tag_id, :integer
  end
end
