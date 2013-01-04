class Location < ActiveRecord::Base
	attr_accessible :address1, :address2, :city, :country, :postal_code, :profile_id, :region, :search_area_tag_id
	
	belongs_to :profile
	belongs_to :search_area_tag
	
	def display_address
		addr = join_present_attrs ', ', :address1, :address2, :city, :region, :country
		addr += " #{postal_code}" if postal_code.present?
		addr
	end
end
