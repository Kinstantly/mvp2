class Service < ActiveRecord::Base
	has_paper_trail # Track changes to each service.
	
	attr_accessible :name, :is_predefined, :specialty_ids, :display_order, :show_on_home_page
	
	# Strip leading and trailing whitespace from (admin) input intended for these attributes.
	auto_strip_attributes :name
	
	has_and_belongs_to_many :profiles
	
	has_and_belongs_to_many :categories
	
	has_many :service_subcategories
	has_many :subcategories, through: :service_subcategories
	
	has_and_belongs_to_many :specialties
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :belongs_to_a_subcategory, joins(:subcategories).order('lower(services.name)') # may contain duplicates
	scope :predefined, where(is_predefined: true)
	scope :order_by_name, order('lower(name)')
	scope :display_order, order(:display_order)
	scope :for_home_page, where(show_on_home_page: true)
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	validates :display_order, numericality: {only_integer: true}, allow_nil: true
	
	after_save :touch_category_lists
	
	paginates_per 20 # Default number shown per page in index listing.
	
	include CachingForModel
	predefined_info_parent :category
	
	include SunspotIndexing
	
	def browsable?
		categories.any? &:browsable?
	end
	
	# Specialties that are eligible to be assigned to this service.
	# Includes specialties that are already assigned even if they are not predefined.
	def assignable_specialties
		(Specialty.predefined + specialties).sort_by(&:lower_case_name).uniq
	end
	
	private
	
	# Touch all category lists that this service belongs to.
	def touch_category_lists
		(categories.map &:category_lists).flatten.uniq.map &:touch
	end
end
