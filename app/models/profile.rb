class Profile < ActiveRecord::Base
	attr_accessor :custom_categories, :custom_services, :custom_specialties
	
	attr_accessible :first_name, :last_name, :middle_name, :credentials, :email, 
		:company_name, :url, :locations_attributes, 
		:mobile_phone, :office_phone, 
		:headline, :education, :experience, :certifications, :awards, 
		:languages, :insurance_accepted, :summary, 
		:category_ids, :service_ids, :specialty_ids, :age_range_ids, 
		:custom_service_names, :custom_specialty_names, :specialties_description, 
		:consult_in_person, :consult_by_email, :consult_by_phone, :consult_by_video, 
		:visit_home, :visit_school, 
		:rates, :availability, 
		:office_hours, :phone_hours, :video_hours, :accepting_new_clients
	
	belongs_to :user
	has_and_belongs_to_many :age_ranges
	has_and_belongs_to_many :categories
	has_and_belongs_to_many :services
	has_and_belongs_to_many :specialties
	
	has_many :locations, dependent: :destroy
	accepts_nested_attributes_for :locations
	
	validates :categories, length: {is: 1, message: "must be chosen"}
	validates :availability, :awards, :education, :experience, :insurance_accepted, :rates, :summary, 
		:office_hours, :phone_hours, :video_hours, length: {maximum: 1000}
	
	# Merge in custom categories and specialties.
	before_validation do
		self.categories = ((categories.presence || []) + (custom_categories.presence || [])).uniq
		self.services = ((services.presence || []) + (custom_services.presence || [])).uniq
		self.specialties = ((specialties.presence || []) + (custom_specialties.presence || [])).uniq
	end
	
	# Solr search configuration.
	searchable do
		text :first_name, :last_name, :middle_name, :credentials, 
			:email, :company_name, :url, :mobile_phone, :office_phone, 
			:headline, :education, :experience, :certifications, :awards, :languages, :insurance_accepted, :summary, 
			:languages, :insurance_accepted, :summary, :rates, :availability, 
			:office_hours, :phone_hours, :video_hours, :specialties_description
		
		text :locations do
			locations.map &:display_address
		end
		text :categories do
			categories.map &:name
		end
		text :services do
			services.map &:name
		end
		text :specialties do
			specialties.map &:name
		end
		
		boolean :is_published
		boolean :consult_by_email
		boolean :consult_by_phone
		boolean :consult_by_video
		boolean :visit_home
		boolean :visit_school
		boolean :accepting_new_clients
		integer :age_range_ids, multiple: true
		integer :category_ids, multiple: true
		integer :service_ids, multiple: true
		integer :specialty_ids, multiple: true
		
		integer :search_area_tag_ids, multiple: true do
			locations.map{|loc| loc.search_area_tag.try(:id)}.compact
		end
		
		string :last_name do
			last_name.strip.downcase
		end
		
		# For highlighting.
		text :summary, stored: true
	end
	
	# By default, only search published profiles.
	# For explanation of mm param, see
	#  http://lucene.apache.org/solr/4_0_0/solr-core/org/apache/solr/util/doc-files/min-should-match.html
	# Use the is_published scope only if the published_only option is true.  Default is to restrict to published profiles.
	# Use the search_area_tag_ids scope only if the search_area_tag_id or search_area_tag_ids options have value(s).
	def self.fuzzy_search(query, new_opts={})
		opts = {published_only: true}.merge(new_opts)
		opts[:search_area_tag_ids] = [opts[:search_area_tag_id]] if opts[:search_area_tag_id].present?
		opts[:search_area_tag_ids].delete_if(&:blank?) if opts[:search_area_tag_ids].present?
		Profile.search do
			adjust_solr_params { |params|
				params[:mm] = '2<-1 4<-2 6<50%'
			}
			fulltext(query) {
				query_phrase_slop 1
			}
			with :search_area_tag_ids, opts[:search_area_tag_ids] if opts[:search_area_tag_ids].present?
			with :is_published, true if opts[:published_only]
		end
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
	
	def display_name
		name = join_present_attrs ' ', :first_name, :middle_name, :last_name
		name += ", #{credentials}" if credentials.present?
		name
	end
	
	def display_name_or_company
		first_name.present? || last_name.present? ? display_name : (company_name.presence || '')
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
