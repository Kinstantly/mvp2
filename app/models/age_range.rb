class AgeRange < ActiveRecord::Base
	# attr_accessible :name, :sort_index

	has_and_belongs_to_many :profiles
	
	scope :active, where(active: true)
	scope :sorted, order(:sort_index)
end
