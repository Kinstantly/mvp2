class CreateProfilesSpecialties < ActiveRecord::Migration
	def change
		create_table :profiles_specialties do |t|
			t.integer :profile_id
			t.integer :specialty_id
		end
	end
end
