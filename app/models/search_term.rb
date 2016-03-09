class SearchTerm < ActiveRecord::Base
	# Remove the following after upgrading to Rails 4.0 or greater.
	include ActiveModel::ForbiddenAttributesProtection
	
	has_paper_trail # Track changes to each search term.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :name ]
	
	attr_protected :id # config.active_record.whitelist_attributes=true but we want it to be effectively false for selected models for which we want strong parameters to do the work.
	
	# Strip leading and trailing whitespace from (admin) input intended for these attributes.
	auto_strip_attributes :name
	
	has_and_belongs_to_many :specialties
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :order_by_name, order('lower(name)')
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	
	include SunspotIndexing
end
