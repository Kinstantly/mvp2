class Profile < ActiveRecord::Base
	attr_accessor :custom_categories, :custom_specialties
	
	attr_accessible :first_name, :last_name, :middle_name, :credentials, :email, 
		:company_name, :url, 
		:address1, :address2, :city, :region, :country, :postal_code, 
		:mobile_phone, :office_phone, 
		:headline, :subcategory, :education, :experience, :certifications, :awards, 
		:languages, :insurance_accepted, :summary, 
		:age_range_ids, 
		:categories, :category_names, :custom_category_names, 
		:specialties, :specialty_names, :custom_specialty_names, 
		:consult_by_email, :consult_by_phone, :consult_by_video, :visit_home, :visit_school, 
		:rates, :availability
	
	belongs_to :user
	has_and_belongs_to_many :age_ranges
	
	serialize :categories, Array
	serialize :specialties, Array
	
	validates_presence_of :first_name, :last_name, message: "is required"
	validates_presence_of :categories, :specialties, message: "must be chosen"
	
	# Merge in custom categories and specialties.
	before_validation do
		self.categories = ((categories.presence || []) + (custom_categories.presence || [])).uniq
		self.specialties = ((specialties.presence || []) + (custom_specialties.presence || [])).uniq
	end
	
	def category_names=(names=[])
		self.categories = remove_blanks names
	end
	
	def custom_category_names=(names=[])
		self.custom_categories = remove_blanks names
	end
	
	def specialty_names=(names=[])
		self.specialties = remove_blanks names
	end
	
	def custom_specialty_names=(names=[])
		self.custom_specialties = remove_blanks names
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
	
	private
	
	def remove_blanks(strings=[])
		strings.select(&:present?)
	end
end
