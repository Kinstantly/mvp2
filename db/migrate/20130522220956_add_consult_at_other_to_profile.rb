class AddConsultAtOtherToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :consult_at_other, :boolean
	end
end
