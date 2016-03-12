class Category < ActiveRecord::Base
	has_paper_trail # Track changes to each category.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :name, :is_predefined, :service_ids, :display_order, :home_page_column, :see_all_column ]
	
	# Strip leading and trailing whitespace from (admin) input intended for these attributes.
	auto_strip_attributes :name
	
	has_and_belongs_to_many :category_lists
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :services, after_add: :services_changed, after_remove: :services_changed
	has_many :category_subcategories do
		def for_subcategory(subcategory)
			where subcategory_id: subcategory
		end
	end
	has_many :subcategories, through: :category_subcategories, after_add: :subcategories_changed, after_remove: :subcategories_changed do
		def by_display_order
			order(CategorySubcategory.table_name + '.subcategory_display_order')
		end
	end
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :predefined, where(is_predefined: true)
	scope :order_by_name, order('lower(name)')
	scope :display_order, order(:display_order)
	scope :home_page_order, order(:home_page_column)
	
	MAX_STRING_LENGTH = 254
	HOME_PAGE_COLUMNS = 1..5
	SEE_ALL_COLUMNS = 1..3
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	validates :display_order, numericality: {only_integer: true}, allow_nil: true
	validates :home_page_column, numericality: {only_integer: true, greater_than_or_equal_to: HOME_PAGE_COLUMNS.first, less_than_or_equal_to: HOME_PAGE_COLUMNS.last}, allow_nil: true
	# validates :see_all_column, numericality: {only_integer: true, greater_than_or_equal_to: SEE_ALL_COLUMNS.first, less_than_or_equal_to: SEE_ALL_COLUMNS.last}, allow_nil: true
	# validates :see_all_column, presence: true, if: :is_predefined
	
	after_save :update_category_lists
	after_save :touch_category_lists
	
	include CachingForModel
	
	include SunspotIndexing
	
	def category_subcategory(subcategory)
		category_subcategories.for_subcategory(subcategory).first if subcategory
	end
	
	def browsable?
		!!is_predefined
	end
	
	# Services that are eligible to be assigned to this category.
	# Includes services that are already assigned even if they are not predefined.
	def assignable_services
		(Service.predefined + services).sort_by(&:lower_case_name).uniq
	end
	
	# Array of this category's services to be displayed on the home page, sorted by display_order, then name.
	def services_for_home_page
		services.for_home_page.display_order.order_by_name
	end
	
	# Array of this category's services to be displayed on the see-all page, sorted by display_order, then name.
	def services_for_see_all_page
		services.display_order.order_by_name
	end
	
	def subcategories_changed(subcategory)
		touch_category_lists
	end
	
	private
	
	# Ensure this category belongs to the proper category lists.
	# Modify the category_list.categories association to ensure the category_list gets touched for caching purposes (see the category_list model).
	def update_category_lists
		all_list = CategoryList.all_list
		home_list = CategoryList.home_list
		if is_predefined
			all_list.categories << self unless category_lists.include? all_list
			if home_page_column
				home_list.categories << self unless category_lists.include? home_list
			else
				home_list.categories.delete self if category_lists.include? home_list
			end
		else
			all_list.categories.delete self if category_lists.include? all_list
			home_list.categories.delete self if category_lists.include? home_list
		end
	end
	
	# Touch all category lists that this category belongs to.
	def touch_category_lists
		category_lists.map &:touch
	end
	
	def services_changed(service)
		touch_category_lists
	end
end
