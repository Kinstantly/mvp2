class CacheLocationsCount < ActiveRecord::Migration
	def up
		execute 'update profiles set locations_count=(select count(*) from locations where profile_id=profiles.id)'
	end

	def down
	end
end
