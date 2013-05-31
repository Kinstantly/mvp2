class CreateAdminEvents < ActiveRecord::Migration
	def change
		create_table :admin_events do |t|
			t.string :name
			t.boolean :trash, default: false

			t.timestamps
		end
	end
end
