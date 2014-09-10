class AddMarketingEmailsAndNewslettersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :parent_marketing_emails, :boolean, :default => false
    add_column :users, :parent_newsletters, :boolean, :default => false
    add_column :users, :provider_marketing_emails, :boolean, :default => false
    add_column :users, :provider_newsletters, :boolean, :default => false
  end
end
