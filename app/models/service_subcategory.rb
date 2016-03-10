class ServiceSubcategory < ActiveRecord::Base
	# Remove the following after upgrading to Rails 4.0 or greater.
	include ActiveModel::ForbiddenAttributesProtection
	
	def self.table_name
		'services_subcategories'
	end
	
	# attr_accessible :service_id, :subcategory_id, :service_display_order
	
	attr_protected :id # config.active_record.whitelist_attributes=true but we want it to be effectively false for selected models for which we want strong parameters to do the work.
	
	belongs_to :service, inverse_of: :service_subcategories
	belongs_to :subcategory, inverse_of: :service_subcategories
	
	after_save :notify_subcategory
	
	private
	
	def notify_subcategory
		subcategory.services_changed service
	end
end
