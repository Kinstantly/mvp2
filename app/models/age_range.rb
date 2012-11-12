class AgeRange < ActiveRecord::Base
	attr_accessible :name, :sort_index

	has_and_belongs_to_many :profiles
end
