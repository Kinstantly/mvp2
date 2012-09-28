class CreateAgeRangesProfiles < ActiveRecord::Migration
	def change
		create_table :age_ranges_profiles do |t|
			t.integer :age_range_id
			t.integer :profile_id
		end
	end
end
