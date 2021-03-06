class Location < ActiveRecord::Base
	has_paper_trail # Track changes to each location.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [:address1, :address2, :city, :region, :postal_code, :country, :phone, :note, :search_area_tag_id]
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :address1, :address2, :city, :region, :postal_code, :country, :phone, :note
	
	# Touch the associated profile to change the cache_key for its fragment caches.
	belongs_to :profile, counter_cache: true, touch: true
	
	belongs_to :search_area_tag

	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MAX_LENGTHS = {
		address1: 250, address2: 250, city: 100, region: 100, postal_code: 20, country: 100,
		phone: PhoneNumberValidator::MAX_LENGTH,
		note: 150
	}

	# Note: length of the phone attribute is checked by the phone number validator.
	[:address1, :address2, :city, :region, :postal_code, :country, :note].each do |attribute|
			validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
		end
	
	validates :phone, phone_number: true, allow_blank: true
	
	# The following scope is desgined to work well with autocomplete.
	# See https://github.com/bigtunacan/rails-jquery-autocomplete/issues/45
	# This SELECT statement is compatible with "ORDER BY LOWER(city)".
	# "SELECT DISTINCT city" is not compatible.
	scope :unique_by_city, -> { select('MIN(id) as id, city').group(:city) }
	
	scope :order_by_id, -> { order(:id) }
	
	geocoded_by :geocodable_address # can also be an IP address
	before_save :geocode_address    # auto-fetch coordinates
	
	# Address without city, region, postal code, and country.
	def street_address
		join_present_attrs ', ', :address1, :address2
	end
	
	def display_city_region
		join_present_attrs ', ', :city, :region
	end
	
	def display_city_region_postal_code
		addr = join_present_attrs ', ', :city, :region
		[addr.presence, postal_code.presence].compact.join(' ')
	end
	
	def display_country
		Carmen::Country.coded(country).try(:name)
	end
	
	def display_region
		Carmen::Country.coded(country).try(:subregions).try(:coded, region).try(:name)
	end
	
	def display_address
		addr = join_present_attrs ', ', :address1, :address2, :city, :region
		[addr.presence, postal_code.presence].compact.join(' ')
	end
	
	def search_address
		[display_address, display_region, display_country].compact.join(' ')
	end
	
	def geocodable_address
		addr = join_present_attrs ', ', :address1, :city, :region
		addr = [addr.presence, postal_code.presence].compact.join(' ')
		# If only country is returned, we get coordinates in the middle of the country which can be misleading.
		addr += ", #{display_country}" if addr.present? and country.present?
		addr
	end
	
	# Always return an array with latitude and longitude values, even if address failed geocoding (in which case, values are nil).
	def geocode_address
		sleep 0.1 # Throttle. We get blocked if we hit Google (perhaps other services too) with multiple, rapid requests.
		(geocodable_address.present? and geocode) or (self.latitude, self.longitude = nil, nil)
	end
	
	def coordinates
		Sunspot::Util::Coordinates.new(latitude, longitude)
	end
	
	def display_phone
		display_phone_number phone
	end
	
	def search_phone
		display_phone_number phone, true # Show country code.
	end
end
