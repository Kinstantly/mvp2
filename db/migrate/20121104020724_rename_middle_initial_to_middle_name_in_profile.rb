class RenameMiddleInitialToMiddleNameInProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.rename :middle_initial, :middle_name
	end
end
