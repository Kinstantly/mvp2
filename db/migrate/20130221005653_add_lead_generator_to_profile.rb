class AddLeadGeneratorToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :lead_generator, :string
  end
end
