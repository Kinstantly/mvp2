namespace :kinstantly_profiles do

	def min_width(obj, n)
		s = obj.to_s
		padding = n - s.length
		padding > 0 ? s + ' ' * padding : s
	end
	
	desc 'Associate the specified categories, subcategories, and services by parsing the admin_notes collection of each profile.'
	task admin_notes_to_categories_subcategories_services: [:environment] do
		options = {}
		options[:batch_size] = ENV['batch_size'].presence.try(:to_i) || 100
		start = ENV['batch_start'].presence.try(:to_i)
		options[:start] = start if start
		
		batch_size = options[:batch_size]
		doing_single_batch = ENV['single_batch'].present?
		doing_dry_run = ENV['dry_run'].present?
		
		progress_i = 0
		progress_batch = progress_batch_size = 100
		
		types = {c: Category, sc: Subcategory, s: Service}
		collections = {c: :categories, sc: :subcategories, s: :services}
		
		Profile.find_each(options) do |profile|
			if (admin_notes = profile.admin_notes).present?
				types.each do |key, type|
					pattern = '^\s*' + key.to_s + ':\s*(\S.*)$'
					admin_notes.scan(Regexp.new pattern) do |match|
						name = match.first.strip.downcase
						record = type.where('lower(name) = ?', name).first
						if record
							unless doing_dry_run
								collection = collections[key]
								profile.send(collection) << record unless profile.send(collection).include?(record)
							else
								puts "dry_run: #{min_width profile.id, 8}#{min_width type, 16}#{record.name}"
							end
						else
							puts "#{profile.id};#{key};#{type};#{name}"
						end
					end
				end
			end
			
			if (progress_i += 1) >= progress_batch
				puts "Finished #{progress_batch}. Profile.id = #{profile.id}"
				progress_batch += progress_batch_size
			end
			
			exit if doing_single_batch and progress_i >= batch_size
		end
	end

end
