class CreateSearchTerms < ActiveRecord::Migration
	def change
		create_table :search_terms do |t|
			t.string :name
			t.boolean :trash, default: false
			
			t.timestamps
		end
		
		create_table :search_terms_specialties do |t|
			t.integer :search_term_id
			t.integer :specialty_id
		end
	end
end
