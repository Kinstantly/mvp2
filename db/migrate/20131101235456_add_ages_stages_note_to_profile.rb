class AddAgesStagesNoteToProfile < ActiveRecord::Migration
	class Profile < ActiveRecord::Base
	end
	
	def up
		add_column :profiles, :ages_stages_note, :text
		
		# Seed ages_stages_note from ages.
		# Ages text data can be used to inform manual setting of the new stages check boxes.
		Profile.reset_column_information
		Profile.all.each do |profile|
			if (ages = profile.ages).present?
				profile.update_column :ages_stages_note, ages
			end
		end
	end
	
	def down
		remove_column :profiles, :ages_stages_note
	end
end
