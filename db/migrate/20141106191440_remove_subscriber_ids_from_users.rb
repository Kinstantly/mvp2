class RemoveSubscriberIdsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :subscriber_euid
    remove_column :users, :subscriber_leid
  end

  def down
    add_column :users, :subscriber_leid, :string
    add_column :users, :subscriber_euid, :string
  end
end
