class PopulateAgeRanges < ActiveRecord::Migration
	@@age_ranges = ['0 to 6', '6 to 12', '12 to 18', '18+']
	
	class AgeRange < ActiveRecord::Base
		# attr_accessible :name
	end
	
	def up
		AgeRange.reset_column_information
		@@age_ranges.each do |name|
			AgeRange.create(name: name)
		end
	end

	def down
		AgeRange.reset_column_information
		@@age_ranges.each do |name|
			c = AgeRange.find_by_name name
			c.destroy if c
		end
	end
end
