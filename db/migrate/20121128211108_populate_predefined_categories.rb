class PopulatePredefinedCategories < ActiveRecord::Migration
	@@categories = ["addiction therapist", "allergist", "baby-proofing/home safety consultant", "babysitter/mother's helper", "bachelor's-level therapist", "board-certified behavior analyst", "child psychiatrist", "child/clinical psychologist", "college admissions prep", "college financial aid counselor", "couples/family therapist", "developmental-behavioral pediatrician", "doula", "eating disorders specialist", "fertility specialist", "genetics counselor", "home allergens inspector", "lactation/feeding consultant/counselor", "learning disabilities specialist", "master's-level therapist", "midwife", "music instructor", "nutritionist", "ob-gyn", "occupational therapist", "parenting coach/educator", "pediatric dentist", "pediatrician", "physical therapist", "reading/dyslexia specialist", "school advocate", "sleep expert", "speech therapist", "tutor"]
	
	class Category < ActiveRecord::Base
		# attr_accessible :name, :is_predefined
		has_and_belongs_to_many :profiles
		has_and_belongs_to_many :specialties
	end
	
	class Profile < ActiveRecord::Base
		has_and_belongs_to_many :categories
	end
	
	class Specialty < ActiveRecord::Base
		has_and_belongs_to_many :categories
	end
	
	def up
		Category.reset_column_information
		Profile.reset_column_information
		Specialty.reset_column_information
		Category.all.each(&:destroy)
		@@categories.each do |name|
			Category.create(name: name, is_predefined: true)
		end
	end

	def down
		Category.reset_column_information
		Profile.reset_column_information
		Specialty.reset_column_information
		@@categories.each do |name|
			c = Category.find_by_name name
			c.destroy if c
		end
	end
end
