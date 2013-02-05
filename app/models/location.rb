class Location < ActiveRecord::Base
	attr_accessible :address1, :address2, :city, :country, :postal_code, :profile_id, :region, :search_area_tag_id
	
	belongs_to :profile
	belongs_to :search_area_tag
	
	scope :unique_by_city, select(:city).uniq
	
	def display_address
		addr = join_present_attrs ', ', :address1, :address2, :city, :region, :country
		addr += " #{postal_code}" if postal_code.present?
		addr
	end
	
	def search_address
		region_name = Carmen::Country.coded(country).try(:subregions).try(:coded, region).try(:name)
		[display_address, region_name].compact.join(' ')
	end
end
