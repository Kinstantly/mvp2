class Profile < ActiveRecord::Base
	DEFAULT_PHOTO_PATH = 'profile-photo-placeholder.jpg'

	has_paper_trail # Track changes to each profile.
	
	attr_writer :custom_service_names, :custom_specialty_names # readers defined below
	
	attr_accessible :first_name, :last_name, :middle_name, :credentials, :email, 
		:company_name, :url, :locations_attributes, :reviews_attributes, 
		:headline, :education, :certifications, :year_started, 
		:languages, :insurance_accepted, :summary, 
		:category_ids, :service_ids, :specialty_ids, 
		:custom_service_names, :custom_specialty_names, 
		:consult_in_person, :consult_in_group, :consult_by_email, :consult_by_phone, :consult_by_video, 
		:visit_home, :visit_school, :consult_at_hospital, :consult_at_camp, :consult_at_other, 
		:pricing, :service_area, :hours, :accepting_new_clients, :availability_service_area_note,
		:invitation_email, :photo_source_url, :profile_photo,
		:adoption_stage, :preconception_stage, :pregnancy_stage, :ages, 
		:consult_remotely # provider offers most or all services remotely
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :first_name, :last_name, :middle_name, :credentials, :email, :company_name, :url,
		:headline, :year_started, :invitation_email, :photo_source_url, :availability_service_area_note
	
	belongs_to :user
	# has_and_belongs_to_many :age_ranges # superseded by *_stage and ages attributes
	has_and_belongs_to_many :categories
	has_and_belongs_to_many :services
	has_and_belongs_to_many :specialties
	
	has_many :locations, dependent: :destroy
	accepts_nested_attributes_for :locations, allow_destroy: true, limit: 100
	
	has_many :reviews, dependent: :destroy
	accepts_nested_attributes_for :reviews, allow_destroy: true, limit: 1000
	
	has_many :ratings, through: :reviews
	has_many :reviewers, through: :reviews

	has_attached_file :profile_photo,
					:styles => {:medium => '110x110', :original => '300x300' }
	
	validate :publishing_requirements
	# validates :categories, length: {maximum: 1}
	validates :email, email: true, allow_blank: true
	validates :invitation_email, email: true, allow_blank: true
	validates_attachment :profile_photo, :content_type => {:content_type => ['image/jpeg', 'image/jpg', 'image/gif', 'image/png']},
											 :size => {:less_than => 5.megabyte}

	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MAX_LENGTHS = {
		first_name: 50,
		middle_name: 50,
		last_name: 50,
		credentials: 50,
		email: EmailValidator::MAX_LENGTH,
		company_name: 200,
		url: 250,
		headline: 200,
		certifications: 250,
		languages: 200,
		invitation_email: EmailValidator::MAX_LENGTH,
		lead_generator: 250,
		photo_source_url: 250,
		ages: 150,
		year_started: 100,
		education: 1000,
		insurance_accepted: 750,
		pricing: 750,
		summary: 1250,
		service_area: 750,
		availability_service_area_note: 750,
		hours: 750,
		admin_notes: 2000,
		custom_service_names: 150,
		custom_specialty_names: 150
	}

	# Note: lengths of the email and invitation_email attributes are checked by the email validator.
	[:first_name, :middle_name, :last_name, :credentials, :company_name, :url, :headline, :certifications,
		:languages, :lead_generator, :photo_source_url, :ages, :year_started, :education,
		:insurance_accepted, :pricing, :summary, :service_area, :hours, :admin_notes,
		:availability_service_area_note].each do |attribute|
			validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
		end
	
	validates_each :custom_service_names, :custom_specialty_names do |record, attribute, names|
		max_length = MAX_LENGTHS[attribute]
		names.each do |name|
			record.errors.add attribute, I18n.t("models.profile.#{attribute}.too_long", max: max_length) if name.length > max_length
		end
	end

	before_save do
		# Merge in custom services and specialties.
		self.services = (services + custom_service_names.map(&:to_service)).uniq
		self.specialties = (specialties + custom_specialty_names.map(&:to_specialty)).uniq
		# No periods in credentials.
		self.credentials = credentials.try(:delete, '.')
	end
	
	after_save do
		# Custom services and specialties are now merged and saved, so we don't need their names (especially for AJAX updates).
		self.custom_service_names, self.custom_specialty_names = nil, nil
	end
	
	scope :order_by_id, order('id')
	scope :order_by_last_name, order('lower(last_name)')
	scope :unique_by_lead_generator, select(:lead_generator).uniq
	scope :with_admin_notes, where('admin_notes IS NOT NULL')
	
	# Sunspot Solr search configuration.
	searchable do
		text :first_name, :last_name, :middle_name, :credentials, 
			:email, :company_name, :url, 
			:headline, :education, :certifications, :hours, 
			:languages, :insurance_accepted, :pricing, :service_area
		
		# Stored for highlighting.
		text :summary, stored: true
		
		text :addresses do
			locations.map &:search_address
		end
		text :cities, boost: 2.0 do
			locations.map &:city
		end
		text :phones do
			locations.map &:search_phone
		end
		latlon :first_location do
			locations.first.coordinates if locations.first
		end
		latlon :locations, multiple: true do
			locations.map &:coordinates
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
		text :search_terms do
			specialties.map{|spec| spec.search_terms.map &:name}.flatten.uniq
		end
		
		boolean :is_published
		boolean :accepting_new_clients
		integer :category_ids, multiple: true
		integer :service_ids, multiple: true
		integer :specialty_ids, multiple: true
		
		integer :search_area_tag_ids, multiple: true do
			locations.map{|loc| loc.search_area_tag.try(:id)}.compact
		end
		
		string :last_name do
			(last_name || '').strip.downcase
		end
	end
	
	# Profiles that have the specified service assigned to them should be boosted to the top of the results.
	# Profiles that exactly match the service name in a full-text search should follow.
	def self.search_by_service(service, new_opts={})
		opts = {
			phrase_fields: {services: 10.0}
		}.merge(new_opts)
		self.configurable_search("\"#{service.name}\"", opts) # Specify service name as a phrase.
	end
	
	# Allow one non-matching word between words in a phrase.
	# Use the "Min Number Should Match" ('mm') Solr parameter.
	# For explanation of mm param, see
	#  http://lucene.apache.org/solr/4_0_0/solr-core/org/apache/solr/util/doc-files/min-should-match.html
	def self.fuzzy_search(query, new_opts={})
		opts = {
			solr_params: {mm: '2<-1 4<-2 6<50%'},
			query_phrase_slop: 1
		}.merge(new_opts)
		self.configurable_search(query, opts)
	end
	
	# By default, only search published profiles.
	# Use the is_published scope only if the published_only option is true.  Default is to restrict to published profiles.
	# Use the search_area_tag_ids scope only if the search_area_tag_id or search_area_tag_ids options have value(s).
	def self.configurable_search(query, new_opts={})
		opts = {
			published_only: true,
			per_page: (SEARCH_DEFAULT_PER_PAGE.presence || nil)
		}.merge(new_opts)
		opts[:search_area_tag_ids] = [opts[:search_area_tag_id]] if opts[:search_area_tag_id].present?
		opts[:search_area_tag_ids].delete_if(&:blank?) if opts[:search_area_tag_ids].present?
		if opts[:address].present?
			opts[:order_by_distance] = self.geocode_address opts[:address]
		elsif opts[:location]
			opts[:order_by_distance] = self.geocode_location opts[:location]
		end
		
		self.search do
			if opts[:solr_params].present?
				adjust_solr_params do |params|
					params.merge! opts[:solr_params]
				end
			end
			
			fulltext(query) do
				query_phrase_slop opts[:query_phrase_slop] if opts[:query_phrase_slop].present?
				boost_fields opts[:boost_fields] if opts[:boost_fields].present?
				phrase_fields opts[:phrase_fields] if opts[:phrase_fields].present?
			end
			
			with :service_ids, opts[:service_id] if opts[:service_id].present?
			with :search_area_tag_ids, opts[:search_area_tag_ids] if opts[:search_area_tag_ids].present?
			with :is_published, true if opts[:published_only]
			
			within_radius = opts[:within_radius]
			with(:locations).in_radius(within_radius[:latitude], within_radius[:longitude], within_radius[:radius_km]) if within_radius.try(:values_present?, :latitude, :longitude, :radius_km)
			
			order_by_distance = opts[:order_by_distance]
			order_by_geodist(:first_location, order_by_distance[:latitude], order_by_distance[:longitude]) if order_by_distance.try(:values_present?, :latitude, :longitude)
			
			paginate_opts = {}
			paginate_opts[:page] = opts[:page].to_i if opts[:page].present?
			paginate_opts[:per_page] = opts[:per_page].to_i if opts[:per_page].present?
			paginate paginate_opts if paginate_opts.present?
		end
	end
	
	# Convert a Location object to a hash with latitude and longitude.
	def self.geocode_location(location)
		latlon = location.geocode_address
		{latitude: latlon[0], longitude: latlon[1]}
	end
	
	# Convert an address string to a hash with latitude and longitude.
	def self.geocode_address(address)
		latlon = address.present? && Geocoder.coordinates(address).presence || [nil, nil]
		{latitude: latlon[0], longitude: latlon[1]}
	end
	
	def custom_service_names
		remove_blanks_and_strip @custom_service_names
	end
	
	def custom_specialty_names
		remove_blanks_and_strip @custom_specialty_names
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

	def photo_path
		if photo_source_url.try(:strip).present?
			photo_source_url.strip
		else
			DEFAULT_PHOTO_PATH
		end
	end
	
	def display_stages_ages
		[(self.class.human_attribute_name :adoption_stage if adoption_stage),
			(self.class.human_attribute_name :preconception_stage if preconception_stage),
			(self.class.human_attribute_name :pregnancy_stage if pregnancy_stage),
			ages.presence].compact.join(', ')
	end
	
	def invite
		if validate_invitable && generate_and_save_invitation_token
			ProfileMailer.invite(self).deliver
			self.invitation_sent_at = Time.zone.now
			errors.add :invitation_sent_at, I18n.t('models.profile.invitation_sent_at.save_error') unless save
		end
		errors.empty?
	end
	
	def claimed?
		!user.nil?
	end
	
	def owned_by?(user)
		user.try(:profile) == self
	end
	
	# If param was used, set to true if param is not blank.
	# If param was not used, do nothing.
	def assign_boolean_param_if_used(attr_name, value)
		send "#{attr_name}=", value.present? if value
	end
	
	# If param was used, set to nil if value only has whitespace, otherwise set to stripped value.
	# If param was not used, do nothing.
	def assign_text_param_if_used(attr_name, value)
		send "#{attr_name}=", value.strip.presence if value
	end
	
	def update_rating_score
		update_attribute :rating_average_score, ratings.average(:score)
	end
	
	def rate(score, user)
		return false unless user
		if score.present?
			rating = rating_by(user).presence || ratings.build
			rating.rater ||= user
			rating.score = score
			return false unless rating.save
		else
			rating_by(user).try(:destroy)
		end
		update_attribute :rating_average_score, ratings.average(:score)
		true
	end
	
	def rating_by(user)
		ratings.find_by_rater_id user.id if user.try(:id)
	end
	
	# Return the array of consultation mode names that are checked for this profile.
	def consultation_modes
		[:visit_home, :consult_by_video, :consult_by_phone, :consult_by_email, :visit_school].map do |attribute|
			 send(attribute) ? self.class.human_attribute_name(attribute) : nil
		end.compact
	end
	
	private
	
	def publishing_requirements
		if is_published
			errors.add :first_name, I18n.t('models.profile.name_and_company.missing') if (first_name.blank? || last_name.blank?) && company_name.blank?
			errors.add :category, I18n.t('models.profile.category.missing') if categories.blank?
		end
	end
	
	# Return an array of hashes holding the id and name values for each of the given items.
	# Do not return values for new (unsaved) items.
	def ids_names(items)
		items.reject(&:new_record?).collect {|item| {id: item.id, name: item.name.html_escape}}
	end
	
	# Validate that an invitation can be sent to claim this profile.
	def validate_invitable
		if claimed?
			errors.add :profile, I18n.t('models.profile.claimed')
		elsif invitation_email.blank?
			errors.add :invitation_email, I18n.t('models.profile.invitation_email.missing')
		end
		errors.empty?
	end
	
	# Return true if this profile is already in the database and
	#   we were able to successfully save the generated token.
	# Otherwise, return false, e.g., if this profile hasn't been saved yet
	#   (we don't want to save for the first time as a side effect).
	def generate_and_save_invitation_token
		self.invitation_token = UUIDTools::UUID.timestamp_create.to_s
		errors.add :invitation_token, I18n.t('models.profile.invitation_token.save_error') unless persisted? && save
		errors.empty?
	end
end
