namespace :import_specialties do
	desc 'List specialty names currently in the database.'
	task specialty_names: :environment do
		Specialty.order_by_name.each do |s|
			puts s.name
		end
	end
	
	desc 'Load the import data.'
	task :load_lines do
		@import_file = ENV['import_file']
		@lines = File.open(@import_file, "r").read
	end
	
	desc 'Parse the categories, services, specialties, and search terms import data.'
	task parse_lines: :load_lines do
		names = {}
		@lines.strip.split("\n").each do |line|
			cat, svc, specs, comments = line.strip.split(';')
			cat.strip!
			svc.strip!
			names[cat] ||= {}
			names[cat][svc] ||= {}
			# Each specialty is separated by a comma and might contain an array of search terms within [], e.g.,
			#   "vegetarianism" ["vegetarian", "vegan"], "vitamins and supplements" ["sports supplements"], "picky eaters"
			while m = /\A\"(.*?)\"\s*(\[.*?\])?\s*,?/.match(specs.strip) do
				spec, terms, specs = m[1].strip, m[2], m.post_match
				names[cat][svc][spec] ||= []
				while tm = /\"(.*?)\"/.match(terms) do
					term, terms = tm[1].strip, tm.post_match
					names[cat][svc][spec] << term unless names[cat][svc][spec].include?(term)
				end
			end if specs
			@names = names
		end
	end
	
	def predefine(record)
		unless record.is_predefined
			record.is_predefined = true
			record.save
		end
		record
	end
	
	desc 'Write the imported categories, services, specialties, and search terms to the database'
	task write_specialties: [:environment, :parse_lines] do
		# We should only run this once for this import file.
		admin_event_name = File.basename @import_file
		if AdminEvent.find_by_name admin_event_name
			puts "!!\nwrite_specialties task has already been run for '#{admin_event_name}'.  It cannot be run again for that import file!"
			return
		end
		
		# The following code was for the first run.  Should not be used anymore.
		# We NO longer want the import to reset the predefined status.
		#
		# Assume categories are already manually set up.
		# Specialty.all.each do |spec|
		# 	spec.is_predefined = false
		# 	spec.save
		# end
		# Service.all.each do |svc|
		# 	svc.is_predefined = false
		# 	svc.save
		# end
		
		@names.each do |cat_name, svcs|
			cat = predefine(cat_name.to_category)
			svcs.each do |svc_name, specs|
				unless (svc = svc_name.to_service).is_predefined
					svc.specialties = []
					svc = predefine(svc)
				end
				cat.services << svc unless cat.services.include?(svc)
				specs.each do |spec_name, terms|
					spec = predefine(spec_name.to_specialty)
					svc.specialties << spec unless svc.specialties.include?(spec)
					terms.each do |term_name|
						term = term_name.to_search_term
						spec.search_terms << term unless spec.search_terms.include?(term)
					end
				end
			end
		end
		
		# Prevent running the task again.  You must remove this record to run it again.
		AdminEvent.create name: admin_event_name
		
		puts 'All done!!'
	end
	
	desc 'List specialty names in the import file.'
	task specialty_names_in_file: [:environment, :parse_lines] do
		@names.each do |cat_name, svcs|
			svcs.each do |svc_name, specs|
				specs.each do |spec_name, terms|
					puts spec_name
				end
			end
		end
	end
		
	desc 'List all names in the import file.'
	task names_in_file: [:environment, :parse_lines] do
		@names.each do |cat_name, svcs|
			puts cat_name
			svcs.each do |svc_name, specs|
				puts "\t#{svc_name}"
				specs.each do |spec_name, terms|
					puts "\t\t#{spec_name}"
					terms.each do |term|
						puts "\t\t\t#{term}"
					end
				end
			end
		end
	end
end
