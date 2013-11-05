class UpdateAgeRanges < ActiveRecord::Migration
	NAME_MAPPING = {
		'preconception' => 'Preconception',
		'pregnancy' => 'Pregnancy/Childbirth',
		'0-1' => 'Infants (0-12 months)',
		'1-3' => 'Toddlers (ages 1-3)',
		'3-5' => 'Preschoolers (ages 3-5)'
	}
	
	NEW_AGES = {
		'Grade-schoolers/tweens (ages 5-12)' => {sort_index: 7, start: '5', end: '12'},
		'Teens (ages 13-19)' => {sort_index: 8, start: '13', end: '19'},
		'Young adults/adults (ages 20+)' => {sort_index: 9, start: '20'}
	}
	
	class AgeRange < ActiveRecord::Base
		attr_accessible :name, :sort_index, :start, :end, :active
	end
	
	def up
		AgeRange.reset_column_information
		
		NAME_MAPPING.each do |old_name, new_name|
			AgeRange.find_by_name(old_name).update_attributes! name: new_name, active: true
		end
		
		NEW_AGES.each do |name, attributes|
			AgeRange.create attributes.merge(name: name, active: true)
		end
	end

	def down
		AgeRange.reset_column_information
		
		NAME_MAPPING.each do |old_name, new_name|
			AgeRange.find_by_name(new_name).update_attributes! name: old_name, active: false
		end
		
		NEW_AGES.each do |name, attributes|
			AgeRange.find_by_name(name).destroy
		end
	end
end
