class ServiceSubcategory < ActiveRecord::Base
	def self.table_name
		'services_subcategories'
	end
	
	attr_accessible :service_id, :subcategory_id, :service_display_order
	
	belongs_to :service, inverse_of: :service_subcategories
	belongs_to :subcategory, inverse_of: :service_subcategories
	
	after_save :notify_subcategory
	
	private
	
	def notify_subcategory
		subcategory.services_changed service
	end
end
