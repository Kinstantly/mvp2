class CreateProviderSuggestions < ActiveRecord::Migration
	def change
		create_table :provider_suggestions do |t|
			t.integer :suggester_id
			t.string :suggester_name
			t.string :suggester_email
			t.string :provider_name
			t.string :provider_url
			t.text :description
			t.text :admin_notes

			t.timestamps
		end
	end
end
