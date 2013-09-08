class Category < ActiveRecord::Base
	has_paper_trail # Track changes to each category.
	
	attr_accessible :name, :is_predefined, :service_ids, :display_order, :home_page_column, :see_all_column
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :services
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :predefined, where(is_predefined: true)
	scope :order_by_name, order('lower(name)')
	scope :display_order, order(:display_order)
	
	MAX_STRING_LENGTH = 254
	HOME_PAGE_COLUMNS = 1..2
	SEE_ALL_COLUMNS = 1..3
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	validates :home_page_column, numericality: {only_integer: true, greater_than_or_equal_to: HOME_PAGE_COLUMNS.first, less_than_or_equal_to: HOME_PAGE_COLUMNS.last}, allow_nil: true
	validates :see_all_column, numericality: {only_integer: true, greater_than_or_equal_to: SEE_ALL_COLUMNS.first, less_than_or_equal_to: SEE_ALL_COLUMNS.last}, allow_nil: true
	validates :see_all_column, presence: true, if: :is_predefined
	
	include CachingForModel
	
	include SunspotIndexing
	
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
end
