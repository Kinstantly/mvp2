class CopyProfilePrimaryPhoneToLocationPhone < ActiveRecord::Migration
	class Profile < ActiveRecord::Base
		has_many :locations
	end
	
	class Location < ActiveRecord::Base
		belongs_to :profile
	end
	
	def up
		Profile.reset_column_information
		Location.reset_column_information
		Profile.all.each do |profile|
			if profile.primary_phone.present? && profile.locations.count < 2
				location = (profile.locations.empty? ? profile.locations.build : profile.locations.first)
				if location.phone.blank?
					location.phone = profile.primary_phone
					location.save
				end
			end
		end
	end

	def down
		# Location.reset_column_information
		# Location.all.each do |location|
		# 	location.phone = nil
		# 	location.save
		# end
	end
end
