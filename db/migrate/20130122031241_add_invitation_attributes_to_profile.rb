class AddInvitationAttributesToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :invitation_email, :string
    add_column :profiles, :invitation_token, :string
    add_column :profiles, :invitation_sent_at, :datetime
  end
end
