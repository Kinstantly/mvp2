class RemoveProfileRatings < ActiveRecord::Migration
	class Rating < ActiveRecord::Base
	end
	
	class Profile < ActiveRecord::Base
		# attr_accessible :rating_average_score
	end
	
	def up
		Rating.reset_column_information
		Profile.reset_column_information
		Rating.all.map &:destroy
		Profile.where('rating_average_score is not null').each do |profile|
			profile.update_attribute :rating_average_score, nil
		end
	end

	def down
	end
end
