class Location < ActiveRecord::Base
	attr_accessible :address1, :address2, :city, :country, :postal_code, :profile_id, :region
	
	belongs_to :profile
	
	def display_address
		addr = join_present_attrs ', ', :address1, :address2, :city, :region, :country
		addr += " #{postal_code}" if postal_code.present?
		addr
	end
end
