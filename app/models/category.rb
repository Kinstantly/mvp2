class Category < ActiveRecord::Base
	has_paper_trail # Track changes to each category.
	
	attr_accessible :name, :is_predefined, :service_ids, :display_order
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :services
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :predefined, where(is_predefined: true).order('lower(name)')
	scope :order_by_name, order('lower(name)')
	scope :display_order, order(:display_order)
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	
	include CachingForModel
	
	include SunspotIndexing
	
	def browsable?
		!!is_predefined
	end
end
