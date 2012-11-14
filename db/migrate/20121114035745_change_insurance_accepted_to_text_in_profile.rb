class ChangeInsuranceAcceptedToTextInProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.remove :insurance_accepted
		t.text :insurance_accepted
	end
end
