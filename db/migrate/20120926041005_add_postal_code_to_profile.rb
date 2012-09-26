class AddPostalCodeToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :postal_code, :string
  end
end
