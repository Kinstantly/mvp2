class ChangeSpecialtiesToTextInProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.remove :specialties
		t.text :specialties
	end
end
