class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :profile_id
      t.string :address1
      t.string :address2
      t.string :city
      t.string :region
      t.string :country
      t.string :postal_code

      t.timestamps
    end
  end
end
