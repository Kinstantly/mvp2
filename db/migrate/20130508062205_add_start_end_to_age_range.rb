class AddStartEndToAgeRange < ActiveRecord::Migration
	class AgeRange < ActiveRecord::Base
		# attr_accessible :name, :start, :end
	end
	
	def up
		add_column :age_ranges, :start, :string
		add_column :age_ranges, :end, :string
		AgeRange.reset_column_information
		%w{ 0-1 1-3 3-5 5-8 8-11 11-14 14-18+ }.each do |name|
			age_range = AgeRange.find_by_name name
			age_range.start = name.sub(/-.*$/, '')
			age_range.end = name.sub(/^.*-/, '')
			age_range.save!
		end
	end
	
	def down
		remove_column :age_ranges, :start, :end
	end
end
