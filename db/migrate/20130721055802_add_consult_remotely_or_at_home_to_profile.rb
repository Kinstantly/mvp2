class AddConsultRemotelyOrAtHomeToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :consult_remotely_or_at_home, :boolean
	end
end
