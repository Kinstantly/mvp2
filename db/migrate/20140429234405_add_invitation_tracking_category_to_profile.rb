class AddInvitationTrackingCategoryToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :invitation_tracking_category, :string
	end
end
