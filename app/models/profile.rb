class Profile < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :middle_initial, :credentials, :email, 
		:company_name, :url, :category_id, :age_range_ids, 
		:address1, :address2, :city, :region, :country, :postal_code, 
		:mobile_phone, :office_phone, 
		:headline, :subcategory, :education, :experience, :certifications, :awards, 
		:languages, :insurance_accepted, :summary, :specialties
	
	belongs_to :user
	belongs_to :category
	has_and_belongs_to_many :age_ranges
	
	validates_presence_of :first_name, :last_name, message: "is required"
end
