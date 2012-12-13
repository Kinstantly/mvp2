class CreateProfilesServices < ActiveRecord::Migration
	def change
		create_table :profiles_services do |t|
			t.integer :profile_id
			t.integer :service_id
		end
	end
end
