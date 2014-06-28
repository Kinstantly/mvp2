namespace :kinstantly_import do
	desc 'Load the import data.'
	task :load_lines do
		@import_file = ENV['import_file']
		@lines = File.open(@import_file, "r").read
	end
	
	desc 'Parse the categories, subcategories, and services import data.'
	task parse_lines: :load_lines do
		@names = {}
		@lines.strip.split("\n").each do |line|
			category, subcategory, service = line.strip.split(';')
			category, subcategory = category.strip.titlecase, subcategory.strip.titlecase
			@names[category] ||= {}
			@names[category][subcategory] ||= []
			@names[category][subcategory] << service.strip
		end
	end
	
	def predefine(record)
		unless record.is_predefined
			record.is_predefined = true
			record.save
		end
		record
	end
	
	desc 'Write the imported categories, subcategories, and services to the database'
	task write_categories_subcategories_services: [:environment, :parse_lines] do
		# We should only run this once for this import file.
		admin_event_name = File.basename @import_file
		if AdminEvent.find_by_name admin_event_name
			puts "!!\nThe write_categories_subcategories_services task has already been run for '#{admin_event_name}'.  It cannot be run again for that import file!"
			return
		end
		
		@names.each do |category_name, subcategories|
			category = predefine(category_name.to_category)
			subcategories.each do |subcategory_name, services|
				subcategory = subcategory_name.to_subcategory
				category.subcategories << subcategory unless category.subcategories.include?(subcategory)
				services.each do |service_name|
					service = service_name.to_service
					subcategory.services << service unless subcategory.services.include?(service)
				end
			end
		end
		
		# Prevent running the task again.  You must remove this record to run it again.
		AdminEvent.create name: admin_event_name
		
		puts 'All done!!'
	end
	
	desc 'List specialty names in the import file.'
	task service_names_in_file: [:environment, :parse_lines] do
		@names.each do |category_name, subcategories|
			subcategories.each do |subcategory_name, services|
				services.each do |service_name|
					puts service_name
				end
			end
		end
	end
	
	desc 'List all names in the import file.'
	task names_in_file: [:environment, :parse_lines] do
		@names.each do |category_name, subcategories|
			puts category_name
			subcategories.each do |subcategory_name, services|
				puts "\t#{subcategory_name}"
				services.each do |service_name|
					puts "\t\t#{service_name}"
				end
			end
		end
	end
end
