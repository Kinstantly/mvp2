class AddSignedUpForMailingListsToUser < ActiveRecord::Migration
	def change
		add_column :users, :signed_up_for_mailing_lists, :boolean, default: false
	end
end
