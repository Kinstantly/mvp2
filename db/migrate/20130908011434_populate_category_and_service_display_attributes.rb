class PopulateCategoryAndServiceDisplayAttributes < ActiveRecord::Migration
	class Category < ActiveRecord::Base
		has_and_belongs_to_many :services
	end

	class Service < ActiveRecord::Base
		has_and_belongs_to_many :categories
	end

	def up
		Category.reset_column_information
		
		# Display of categories on home page:
		#   Old rule: display_order doubled to determine a category's display column.
		#   New rules: home_page_column determines where category is displayed.
		#              service.show_on_home_page determines which services are displayed.
		# Display of categories on see-all page:
		#   All predefined categories are displayed.
		#   see_all_column is new.  Seed it by mirroring home_page_column.
		#   Those not previously displayed on home page are put in third column.
		
		Category.where(is_predefined: true).each do |category|
			category.home_page_column = if category.display_order.nil?
				nil
			elsif category.display_order < 10
				1
			else
				2
			end
			
			category.see_all_column = if category.home_page_column.nil?
				3
			else
				category.home_page_column
			end
			
			category.save
			
			category.services.each do |svc|
				svc.show_on_home_page = category.home_page_column.present?
				svc.save
			end
		end
	end

	def down
		Category.reset_column_information
		Category.where(is_predefined: true).each do |category|
			category.home_page_column, category.see_all_column = nil, nil
			category.save
			category.services.each do |svc|
				svc.show_on_home_page = nil
				svc.save
			end
		end
	end
end
