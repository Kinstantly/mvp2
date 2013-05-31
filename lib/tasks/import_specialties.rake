namespace :import_specialties do
	desc 'List specialty names currently in the database.'
	task specialty_names: :environment do
		Specialty.order_by_name.each do |s|
			puts s.name
		end
	end
	
	desc 'Parse the import file.'
	task :parse_lines do
		names = {}
		File.open("tmp/cat_svc_spec", "r").read.strip.split("\n").each do |line|
			cat, svc, specs, comments = line.strip.split(';')
			cat.strip!
			svc.strip!
			names[cat] ||= {}
			names[cat][svc] ||= {}
			# Each specialty is separated by a comma and might contain an array of search terms within [], e.g.,
			#   "vegetarianism" ["vegetarian", "vegan"], "vitamins and supplements" ["sports supplements"], "picky eaters"
			while m = /\A\"(.*?)\"\s*(\[.*?\])?\s*,?/.match(specs.strip) do
				spec, terms, specs = m[1], m[2], m.post_match
				names[cat][svc][spec] ||= []
				while tm = /\"(.*?)\"/.match(terms) do
					term, terms = tm[1], tm.post_match
					names[cat][svc][spec] << term unless names[cat][svc][spec].include?(term)
				end
			end if specs
			@names = names
		end
	end
		
	desc 'List specialty names in the import file.'
	task specialty_names_in_file: [:parse_lines] do
		@names.each do |cat_name, svcs|
			svcs.each do |svc_name, specs|
				specs.each do |spec_name, terms|
					puts spec_name
				end
			end
		end
	end
		
	desc 'List all names in the import file.'
	task names_in_file: [:parse_lines] do
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
