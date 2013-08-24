class AddAssociationIndexes < ActiveRecord::Migration
	def change
		# profile associations
		add_index :age_ranges_profiles, :profile_id
		add_index :categories_profiles, :profile_id
		add_index :locations, :profile_id
		add_index :profiles_services, :profile_id
		add_index :profiles_specialties, :profile_id
		add_index :reviews, :profile_id
		add_index :profiles, :user_id
		# expertise associations
		add_index :categories_services, :category_id
		add_index :categories_services, :service_id
		add_index :search_terms_specialties, :search_term_id
		add_index :search_terms_specialties, :specialty_id
		add_index :services_specialties, :service_id
		add_index :services_specialties, :specialty_id
	end
end
