class Profile < ActiveRecord::Base
	attr_accessor :custom_categories, :custom_services, :custom_specialties
	
	attr_accessible :first_name, :last_name, :middle_name, :credentials, :email, 
		:company_name, :url, :locations_attributes, 
		:mobile_phone, :office_phone, 
		:headline, :education, :experience, :certifications, :awards, 
		:languages, :insurance_accepted, :summary, 
		:category_ids, :service_ids, :specialty_ids, :age_range_ids, 
		:custom_service_names, :custom_specialty_names, 
		:consult_by_email, :consult_by_phone, :consult_by_video, :visit_home, :visit_school, 
		:rates, :availability, 
		:office_hours, :phone_hours, :video_hours, :accepting_new_clients
	
	belongs_to :user
	has_and_belongs_to_many :age_ranges
	has_and_belongs_to_many :categories
	has_and_belongs_to_many :services
	has_and_belongs_to_many :specialties
	
	has_many :locations, dependent: :destroy
	accepts_nested_attributes_for :locations
	
	validates_presence_of :categories, message: "must be chosen"
	
	# Merge in custom categories and specialties.
	before_validation do
		self.categories = ((categories.presence || []) + (custom_categories.presence || [])).uniq
		self.services = ((services.presence || []) + (custom_services.presence || [])).uniq
		self.specialties = ((specialties.presence || []) + (custom_specialties.presence || [])).uniq
	end
	
	def custom_category_names=(names=[])
		self.custom_categories = remove_blanks(names).collect(&:to_category)
	end
	
	def custom_service_names=(names=[])
		self.custom_services = remove_blanks(names).collect(&:to_service)
	end
	
	def custom_specialty_names=(names=[])
		self.custom_specialties = remove_blanks(names).collect(&:to_specialty)
	end
	
	def service_ids_names
		ids_names services
	end
	
	def specialty_ids_names
		ids_names specialties
	end
	
	def require_location
		locations.build if locations.blank?
	end
	
	private
	
	def remove_blanks(strings=[])
		strings.select(&:present?)
	end
	
	# Return an array of hashes holding the id and name values for each of the given items.
	# Do not return values for new (unsaved) items.
	def ids_names(items)
		items.reject(&:new_record?).collect {|item| {id: item.id, name: item.name.html_escape}}
	end
end
