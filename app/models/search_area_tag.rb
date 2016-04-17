class SearchAreaTag < ActiveRecord::Base
	has_many :locations
	
	scope :all_ordered, -> { order('display_order') }
end
