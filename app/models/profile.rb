class Profile < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :middle_name, :credentials, :email, 
		:company_name, :url, 
		:address1, :address2, :city, :region, :country, :postal_code, 
		:mobile_phone, :office_phone, 
		:headline, :subcategory, :education, :experience, :certifications, :awards, 
		:languages, :insurance_accepted, :summary, 
		:age_range_ids, 
		:categories, :categories_updater, :categories_merger, 
		:specialties, :specialties_updater, :specialties_merger
	
	belongs_to :user
	has_and_belongs_to_many :age_ranges
	
	serialize :categories, Array
	serialize :specialties, Array
	
	validates_presence_of :first_name, :last_name, message: "is required"
	
	def categories_updater=(raw=[])
		self.categories = raw.select {|c| c.present?}
	end
	
	def categories_merger=(add=[])
		self.categories_updater = (categories + add).uniq
	end
	
	def specialties_updater=(raw=[])
		self.specialties = raw.select {|c| c.present?}
	end
	
	def specialties_merger=(add=[])
		self.specialties_updater = (specialties + add).uniq
	end
	
	class << self
		def predefined_categories
			@predefined_categories ||= (CATEGORIES_SPECIALTIES_MAP.try(:keys).try(:sort).presence || [])
		end
		
		def categories_specialties_map
			@categories_specialties_map ||= (CATEGORIES_SPECIALTIES_MAP.presence || {})
		end
		
		def predefined_specialties
			@predefined_specialties ||= (CATEGORIES_SPECIALTIES_MAP.try(:values).try(:flatten).try(:uniq).try(:sort).presence || [])
		end
	end
end
