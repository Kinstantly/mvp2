class AddConsultAtHospitalAndCampToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :consult_at_hospital, :boolean
		add_column :profiles, :consult_at_camp, :boolean
	end
end
