class AddConsultInPersonToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :consult_in_person, :boolean
	end
end
