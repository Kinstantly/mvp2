class Category < ActiveRecord::Base
	attr_accessible :name, :is_predefined, :service_ids
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :services
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :predefined, where(is_predefined: true).order('lower(name)')
	scope :order_by_name, order('lower(name)')
	
	include CachingForModel
end
