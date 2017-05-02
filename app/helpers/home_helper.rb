module HomeHelper
	def home_column_categories(column)
		# CategoryList.home_list.categories.where(home_page_column: column).display_order.order_by_name
		Category.where(home_page_column: column).home_page_order
	end
	
	def show_all_column_categories(column)
		CategoryList.all_list.categories.where(see_all_column: column).display_order.order_by_name
	end
	
	def story_teaser_css_class(story_teaser, featured)
		css_classes = "#{story_teaser.css_class}".split
		css_classes << 'featured' if featured
		css_classes.compact.uniq.join(' ')
	end
end
