class Profile < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :middle_initial, :credentials, 
		:company_name, :url, :category_id, 
		:address1, :address2, :city, :region, :country, :postal_code, 
		:mobile_phone, :office_phone, 
		:headline, :subcategory, :education, :experience, :certifications, :awards, 
		:languages, :insurance_accepted, :summary, :specialties
	
	belongs_to :user
	belongs_to :category
	
	validates_presence_of :first_name, :last_name, message: "is required"
end
