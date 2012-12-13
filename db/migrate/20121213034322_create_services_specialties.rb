class CreateServicesSpecialties < ActiveRecord::Migration
	def change
		create_table :services_specialties do |t|
			t.integer :service_id
			t.integer :specialty_id
		end
	end
end
