class AddSearchWidgetCodeToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :search_widget_code, :text
  end
end
