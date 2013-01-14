class RemoveSerializedSpecialtiesFromProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.remove :specialties
	end
end
