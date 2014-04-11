class AddWidgetCodeToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :widget_code, :text
  end
end
