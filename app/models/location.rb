class Location < ActiveRecord::Base
	attr_accessible :address1, :address2, :city, :country, :phone, :postal_code, :profile_id, :region, :search_area_tag_id
	
	belongs_to :profile
	belongs_to :search_area_tag
	
	validates :phone, phone_number: true, allow_blank: true
	
	scope :unique_by_city, select(:city).uniq
	
	geocoded_by :geocodable_address # can also be an IP address
	before_save :geocode_address    # auto-fetch coordinates
	
	def display_address
		addr = join_present_attrs ', ', :address1, :address2, :city, :region
		[addr.presence, postal_code.presence].compact.join(' ')
	end
	
	def search_address
		region_name = Carmen::Country.coded(country).try(:subregions).try(:coded, region).try(:name)
		[display_address, region_name].compact.join(' ')
	end
	
	def geocodable_address
		addr = join_present_attrs ', ', :address1, :city, :region
		[addr.presence, postal_code.presence].compact.join(' ')
		# Do not include country until we go international.
		# If only country is returned, we get coordinates in the middle of the country which can be misleading.
		# [addr.presence, country.presence].compact.join(', ')
	end
	
	def geocode_address
		if geocodable_address.present?
			geocode
		else
			self.latitude, self.longitude = nil, nil
		end
	end
	
	def coordinates
		Sunspot::Util::Coordinates.new(latitude, longitude)
	end
	
	def display_phone
		display_phone_number phone
	end
end
