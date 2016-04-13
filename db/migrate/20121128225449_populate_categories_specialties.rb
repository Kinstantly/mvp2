class PopulateCategoriesSpecialties < ActiveRecord::Migration
	class Category < ActiveRecord::Base
		has_and_belongs_to_many :specialties
		scope :predefined, -> { where(is_predefined: true).order('lower(name)') }
	end

	class Specialty < ActiveRecord::Base
		has_and_belongs_to_many :categories
		scope :predefined, -> { where(is_predefined: true).order('lower(name)') }
	end

	def up
		Category.reset_column_information
		Specialty.reset_column_information
		Category.predefined.each do |cat|
			cat.specialties = Specialty.predefined
		end
	end

	def down
		Category.reset_column_information
		Specialty.reset_column_information
		Category.predefined.each do |cat|
			cat.specialties = []
		end
	end
end
