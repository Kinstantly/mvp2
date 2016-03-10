class AdminEvent < ActiveRecord::Base
	# attr_accessible :name
	
	default_scope where(trash: false)
	scope :trash, where(trash: true)
	scope :order_by_name, order('lower(name)')
	
	MAX_STRING_LENGTH = 254
	
	validates :name, presence: true
	validates :name, length: {maximum: MAX_STRING_LENGTH}
end
