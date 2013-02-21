class RenamePhonesInProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.rename :office_phone, :primary_phone
		t.rename :mobile_phone, :secondary_phone
	end
end
