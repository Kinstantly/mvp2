class Location < ActiveRecord::Base
	attr_accessible :address1, :address2, :city, :country, :postal_code, :profile_id, :region
	
	belongs_to :profile
end
