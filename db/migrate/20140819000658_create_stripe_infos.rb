class CreateStripeInfos < ActiveRecord::Migration
  def change
    create_table :stripe_infos do |t|
      t.references :user
      t.string :stripe_user_id
      t.text :access_token
      t.text :publishable_key
    
      t.timestamps
    end
    add_index :stripe_infos, :user_id
  end
end
