class AddDisplayOrderToSearchAreaTag < ActiveRecord::Migration
	@@bay_area_tag_names = ['San Francisco', 'North Bay', 'East Bay', 'South Bay']
	
	class SearchAreaTag < ActiveRecord::Base
		attr_accessible :name, :display_order
	end
	
	def change
		add_column :search_area_tags, :display_order, :integer
		SearchAreaTag.reset_column_information
		@@bay_area_tag_names.inject(1) do |n, name|
			SearchAreaTag.where(name: name).first_or_create.update_attributes!(display_order: n)
			n + 1
		end
	end
end
