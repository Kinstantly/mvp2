class AddAgesegmentedNewslettersToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :parent_newsletters_stage1_leid, :string
    add_column :users, :parent_newsletters_stage1, :boolean, :default => false
    add_column :users, :parent_newsletters_stage2_leid, :string
    add_column :users, :parent_newsletters_stage2, :boolean, :default => false
    add_column :users, :parent_newsletters_stage3_leid, :string
    add_column :users, :parent_newsletters_stage3, :boolean, :default => false
  end
end
