class Category < ActiveRecord::Base
	attr_accessible :name, :is_predefined
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :specialties
	
	scope :predefined, where(is_predefined: true).order('name')
	
	class << self
		def specialties_map
			map = {}
			all.each do |cat|
				map[cat.id] = cat.specialties if cat.specialties.present?
			end
			map
		end
	end
end
