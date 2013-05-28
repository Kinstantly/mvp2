class Specialty < ActiveRecord::Base
  attr_accessible :name, :is_predefined
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :services
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :predefined, where(is_predefined: true).order('lower(name)')
	scope :order_by_name, order('lower(name)')
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
	
	include CachingForModel
	predefined_info_parent :service
	
	def browsable?
		services.any? &:browsable?
	end
end
