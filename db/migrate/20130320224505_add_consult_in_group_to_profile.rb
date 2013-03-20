class AddConsultInGroupToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :consult_in_group, :boolean
	end
end
