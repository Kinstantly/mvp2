class Profile < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :middle_initial, 
		:company_name, :url, :info, 
		:address1, :address2, :city, :region, :country, :postal_code, 
		:mobile_phone, :office_phone
	
	belongs_to :user
	
	validates_presence_of :first_name, :last_name, message: "is required"
end
