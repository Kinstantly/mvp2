class Service < ActiveRecord::Base
	attr_accessible :name, :is_predefined
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :categories
	has_and_belongs_to_many :specialties
	
	scope :predefined, where(is_predefined: true).order('lower(name)')
end
