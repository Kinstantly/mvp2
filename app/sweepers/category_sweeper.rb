class CategorySweeper < ActionController::Caching::Sweeper
	observe Category
	
	def sweep(category)
		expire_fragment 'home_category_list'
		expire_action controller: :home, action: :show_all_categories
	end
	
	alias_method :after_update, :sweep
	alias_method :after_create, :sweep
	alias_method :after_destroy, :sweep
end
