class Specialty < ActiveRecord::Base
	has_paper_trail # Track changes to each specialty.
	
	attr_writer :search_term_ids_to_remove, :search_term_names_to_add # readers defined below
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [
		:name, :is_predefined,
		{ search_term_ids_to_remove: [], search_term_names_to_add: [] }
	]
	
	# Strip leading and trailing whitespace from (admin) input intended for these attributes.
	auto_strip_attributes :name
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :services
	has_and_belongs_to_many :search_terms, after_add: :reindex_profiles, after_remove: :reindex_profiles
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :predefined, where(is_predefined: true)
	scope :order_by_name, order('lower(name)')
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	
	before_save do
		# Remove search terms marked for removal.
		trimmed_search_terms = search_terms.reject{ |term| search_term_ids_to_remove.include? term.id.to_s }
		# Merge in new search terms and set the new list.
		self.search_terms = (trimmed_search_terms + search_term_names_to_add.map(&:to_search_term)).uniq
	end
	
	after_save do
		# New search terms are now merged and saved, so we don't need their names (especially for AJAX updates).
		self.search_term_names_to_add = nil
	end
	
	paginates_per 20 # Default number shown per page in index listing.
	
	include CachingForModel
	predefined_info_parent :service
	
	include SunspotIndexing
	
	def browsable?
		# services.any? &:browsable?
		true # Specialties are no longer linked to particular services.
	end
	
	def search_term_ids_to_remove
		remove_blanks @search_term_ids_to_remove
	end
	
	def search_term_names_to_add
		remove_blanks @search_term_names_to_add
	end
end
