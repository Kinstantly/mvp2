class AddAvailabilityServiceAreaNoteToProfile < ActiveRecord::Migration
	class Profile < ActiveRecord::Base
	end
	
	def up
		add_column :profiles, :availability_service_area_note, :text
		
		# availability_service_area_note is an expansion of service_area,
		# so seed it from service_area.
		Profile.reset_column_information
		Profile.all.each do |profile|
			if (service_area = profile.service_area).present?
				profile.update_column :availability_service_area_note, service_area
			end
		end
	end
	
	def down
		remove_column :profiles, :availability_service_area_note
	end
end
