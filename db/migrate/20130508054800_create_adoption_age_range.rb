class CreateAdoptionAgeRange < ActiveRecord::Migration
	class AgeRange < ActiveRecord::Base
		# attr_accessible :name, :sort_index
	end
	
	def up
		AgeRange.reset_column_information
		AgeRange.all.each do |age_range|
			age_range.sort_index += 1
			age_range.save!
		end
		AgeRange.create(name: 'adoption', sort_index: 1)
	end
	
	def down
		AgeRange.reset_column_information
		AgeRange.find_by_name('adoption').destroy
		AgeRange.all.each do |age_range|
			age_range.sort_index -= 1
			age_range.save!
		end
	end
end
