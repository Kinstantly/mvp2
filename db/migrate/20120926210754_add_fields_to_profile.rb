class AddFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :headline, :string
    add_column :profiles, :subcategory, :string
    add_column :profiles, :education, :text
    add_column :profiles, :experience, :text
    add_column :profiles, :certifications, :string
    add_column :profiles, :awards, :text
    add_column :profiles, :languages, :string
    add_column :profiles, :insurance_accepted, :boolean
    add_column :profiles, :summary, :text
    add_column :profiles, :specialties, :string
  end
end
