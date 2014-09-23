class AddPermissionUseSuggesterNameToProviderSuggestions < ActiveRecord::Migration
  def change
    add_column :provider_suggestions, :permission_use_suggester_name, :boolean, default: false
  end
end
