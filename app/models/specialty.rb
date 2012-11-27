class Specialty < ActiveRecord::Base
  attr_accessible :name
	
	has_and_belongs_to_many :profiles
	has_and_belongs_to_many :categories
end
