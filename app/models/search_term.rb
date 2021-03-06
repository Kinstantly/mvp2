class SearchTerm < ActiveRecord::Base
	has_paper_trail # Track changes to each search term.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :name ]
	
	# Strip leading and trailing whitespace from (admin) input intended for these attributes.
	auto_strip_attributes :name
	
	has_and_belongs_to_many :specialties
	
	default_scope { where(trash: false) }
	scope :trash, -> { rewhere(trash: true) }
	scope :order_by_name, -> { order('lower(name)') }
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	
	include SunspotIndexing
end
