class Subcategory < ActiveRecord::Base
	has_paper_trail # Track changes to each subcategory.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :name, :service_ids ]
	
	# Strip leading and trailing whitespace from (admin) input intended for these attributes.
	auto_strip_attributes :name
	
	has_and_belongs_to_many :profiles
	
	has_many :category_subcategories
	has_many :categories, through: :category_subcategories
	
	has_many :service_subcategories do
		def for_service(service)
			where service_id: service
		end
	end
	has_many :services, through: :service_subcategories, after_add: :services_changed, after_remove: :services_changed do
		def by_display_order
			order(ServiceSubcategory.table_name + '.service_display_order')
		end
	end

	# has_and_belongs_to_many :services, after_add: :services_changed, after_remove: :services_changed
	
	default_scope { where(trash: false) }
	scope :trash, -> { where(trash: true) }
	# scope :predefined, -> { where(is_predefined: true) }
	scope :order_by_name, -> { order('lower(name)') }
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	
	paginates_per 20 # Default number shown per page in index listing.
	
	after_save :notify_categories
	
	include CachingForModel
	
	include SunspotIndexing
	
	def service_subcategory(service)
		service_subcategories.for_service(service).first if service
	end
	
	def is_predefined
		true
	end
	
	def browsable?
		categories.any? &:browsable?
	end

	def services_changed(service)
		notify_categories
	end
	
	# Services that are eligible to be assigned to this subcategory.
	# Includes services that are already assigned even if they are not predefined.
	# def assignable_services
	# 	(Service.predefined + services).sort_by(&:lower_case_name).uniq
	# end
	
	# Array of this subcategory's services to be displayed on the home page, sorted by display_order, then name.
	# def services_for_home_page
	# 	services.by_display_order.order_by_name
	# end

	private

	def notify_categories
		categories.each { |category| category.subcategories_changed self }
	end
end
