class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_initial
      t.string :company_name
      t.string :url
      t.text :info
      t.string :mobile_phone
      t.string :office_phone
      t.string :address1
      t.string :address2
      t.string :city
      t.string :region
      t.string :country

      t.timestamps
    end
  end
end
