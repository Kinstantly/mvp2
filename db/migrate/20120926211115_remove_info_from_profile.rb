class RemoveInfoFromProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.remove :info
	end
end
