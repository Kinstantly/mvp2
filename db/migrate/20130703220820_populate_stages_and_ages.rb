class PopulateStagesAndAges < ActiveRecord::Migration
	class Profile < ActiveRecord::Base
		has_and_belongs_to_many :age_ranges
	
		def age_ranges_to_ages
			age_ranges.sort_by(&:sort_index).inject([]) { |display_ranges, age_range|
				if (start = age_range.start).present? && (last = display_ranges.last).present? && start == last[:end]
					last[:end] = age_range.end
					last[:name] = "#{last[:start]}-#{last[:end]}"
				elsif age_range.start.present? || age_range.name == 'adults'
					display_ranges << {name: age_range.name, start: age_range.start, end: age_range.end}
				end
				display_ranges
			}.map{ |range| range[:name] }.join(', ')
		end
	end
	
	def up
		Profile.reset_column_information
		adoption_age_range = AgeRange.find_by_name 'adoption'
		preconception_age_range = AgeRange.find_by_name 'preconception'
		pregnancy_age_range = AgeRange.find_by_name 'pregnancy'
		Profile.all.each do |p|
			p.adoption_stage = p.age_ranges.include? adoption_age_range
			p.preconception_stage = p.age_ranges.include? preconception_age_range
			p.pregnancy_stage = p.age_ranges.include? pregnancy_age_range
			p.ages = p.age_ranges_to_ages
			p.save
		end
	end

	def down
	end
end
