class KinstantlyLocationsLog
	def self.location(location)
		profile = location.profile # might be nil
		puts "#{profile.try :display_name_or_company}: profile.id=#{profile.try :id} location.id=#{location.id} latitude=#{location.latitude} longitude=#{location.longitude}"
	end
end

namespace :kinstantly_locations do
	desc 'geocode locations with nil latitude or longitude to repair failed attempts to geocode'
	task geocode_nils: :environment do
		dry_run = ENV['dry_run'].present?
		have_solr_changes = false
		
		Location.where('latitude IS NULL OR longitude IS NULL').each do |location|
			if location.geocodable_address.present? and (dry_run or location.save)
				location.reload
				unless dry_run
					location.profile.try :index # Index profile in Solr with repaired location.
					have_solr_changes = true # Commit changes to Solr index when all done.
				end
				KinstantlyLocationsLog.location location
				sleep 1 # Don't surpass the geocoding API query limit.
			end
		end
		
		Sunspot.commit if have_solr_changes
	end
end
