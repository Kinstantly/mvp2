class Service < ActiveRecord::Base
	attr_accessible :name, :is_predefined, :specialty_ids
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :categories
	has_and_belongs_to_many :specialties
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :belongs_to_a_category, joins(:categories).order('lower(services.name)') # may contain duplicates
	scope :predefined, where(is_predefined: true).order('lower(name)')
	scope :order_by_name, order('lower(name)')
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	
	include CachingForModel
	predefined_info_parent :category
	
	def browsable?
		categories.any? &:browsable?
	end
end
