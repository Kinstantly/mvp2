class RenameOfficeHoursToHoursInProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.rename :office_hours, :hours
	end
end
