module HomeHelper
	def home_column_categories(column)
		Category.predefined.where(home_page_column: column).display_order.order_by_name
	end
	
	def show_all_column_categories(column)
		Category.predefined.where(see_all_column: column).display_order.order_by_name
	end
end
