class AddRatesAndAvailabilityToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :rates, :text
    add_column :profiles, :availability, :text
  end
end
