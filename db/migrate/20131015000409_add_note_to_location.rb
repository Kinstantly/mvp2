class AddNoteToLocation < ActiveRecord::Migration
	def change
		add_column :locations, :note, :string
	end
end
