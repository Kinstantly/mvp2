class CreateAgeRanges < ActiveRecord::Migration
  def change
    create_table :age_ranges do |t|
      t.string :name

      t.timestamps
    end
  end
end
