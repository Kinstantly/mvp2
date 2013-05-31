namespace :import_specialties do
	desc 'List specialty names currently in the database.'
	task specialty_names: :environment do
		Specialty.order_by_name.each do |s|
			puts s.name
		end
	end
	
	desc 'Load the import data.'
	task :load_lines do
		@lines = File.open("lib/data/Copy of Browse by Category clean 20130530.csv", "r").read
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
	
	WRITE_SPECIALTIES_201305 = 'write_specialties_201305'
	
	desc 'Write the imported categories, services, specialties, and search terms to the database'
	task write_specialties: [:environment, :parse_lines] do
		# We should only run this once.
		if AdminEvent.find_by_name WRITE_SPECIALTIES_201305
			puts "!!\nwrite_specialties task has already been run.  It cannot be run again!"
			return
		end
		
		# We want the import to determine which services and specialties are predefined.
		# Assume categories are already manually set up.
		Specialty.all.each do |spec|
			spec.is_predefined = false
			spec.save
		end
		Service.all.each do |svc|
			svc.is_predefined = false
			svc.save
		end
		
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
		AdminEvent.create name: WRITE_SPECIALTIES_201305
		
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
