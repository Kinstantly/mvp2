class RepopulateAgeRangesWithPreconceptionToAdults < ActiveRecord::Migration
	@@old_age_ranges = ['0 to 6', '6 to 12', '12 to 18', '18+']
	@@new_age_ranges = ['preconception', 'pregnancy', '0-1', '1-3', '3-5', '5-8', '8-11', '11-14', '14-18+', 'adults']
	
	class AgeRange < ActiveRecord::Base
		attr_accessible :name, :sort_index
	end
	
	def up
		AgeRange.reset_column_information
		@@old_age_ranges.each do |name|
			age_range = AgeRange.find_by_name name
			age_range.destroy if age_range
		end
		i = 0
		@@new_age_ranges.each do |name|
			AgeRange.create(name: name, sort_index: (i += 1))
		end
	end

	def down
		AgeRange.reset_column_information
		@@new_age_ranges.each do |name|
			age_range = AgeRange.find_by_name name
			age_range.destroy if age_range
		end
		i = 0
		@@old_age_ranges.each do |name|
			AgeRange.create(name: name, sort_index: (i += 1))
		end
	end
end
