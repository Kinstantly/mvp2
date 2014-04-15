namespace :kinstantly_locations do
	desc 'geocode locations with nil latitude or longitude to repair failed attempts to geocode'
	task geocode_nils: :environment do
		dry_run = ENV['dry_run'].present?
		Location.where('latitude IS NULL OR longitude IS NULL').each do |location|
			if location.geocodable_address.present? and (dry_run or location.save)
				location.reload
				puts "#{location.profile.try :display_name_or_company}: id=#{location.id} latitude=#{location.latitude} longitude=#{location.longitude}"
				sleep 1 # Don't surpass the geocoding API query limit.
			end
		end
	end
end
