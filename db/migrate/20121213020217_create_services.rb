class CreateServices < ActiveRecord::Migration
	def change
		create_table :services do |t|
			t.string :name
			t.boolean :is_predefined, default: false

			t.timestamps
		end
	end
end
