class AddSubscriberListIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :parent_marketing_emails_leid, :string
    add_column :users, :parent_newsletters_leid, :string
    add_column :users, :provider_marketing_emails_leid, :string
    add_column :users, :provider_newsletters_leid, :string
  end
end
