class PopulateBayAreaSearchAreaTags < ActiveRecord::Migration
	@@bay_area_tag_names = ['San Francisco', 'North Bay', 'East Bay', 'South Bay']
	
	class SearchAreaTag < ActiveRecord::Base
		has_many :locations
	end

	def up
		SearchAreaTag.reset_column_information
		@@bay_area_tag_names.each do |name|
			SearchAreaTag.where(name: name).first_or_create
		end
	end

	def down
		SearchAreaTag.reset_column_information
		@@bay_area_tag_names.each do |name|
			SearchAreaTag.find_by_name(name).try(:destroy)
		end
	end
end
