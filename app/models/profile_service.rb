class ProfileService < ActiveRecord::Base
	def self.table_name
		'profiles_services'
	end
	
	belongs_to :service
	belongs_to :profile
end
