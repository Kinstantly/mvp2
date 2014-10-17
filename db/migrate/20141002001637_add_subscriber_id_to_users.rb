class AddSubscriberIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscriber_euid, :string
    add_column :users, :subscriber_leid, :string
  end
end
