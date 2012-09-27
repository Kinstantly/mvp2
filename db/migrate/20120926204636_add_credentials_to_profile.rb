class AddCredentialsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :credentials, :string
  end
end
