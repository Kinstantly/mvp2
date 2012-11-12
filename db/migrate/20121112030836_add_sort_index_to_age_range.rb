class AddSortIndexToAgeRange < ActiveRecord::Migration
  def change
    add_column :age_ranges, :sort_index, :integer
  end
end
