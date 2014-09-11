class AddProfileHelpToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_help, :boolean, default: true
  end
end
