class ChangeDataTypeForStartEndDateOfAnnouncement < ActiveRecord::Migration
   def up
	  change_table :announcements do |t|
	    t.change :start_at, :timestamptz
	    t.change :end_at, :timestamptz
	  end
	end
	 
	def down
	  change_table :announcements do |t|
	    t.change :start_at, :datetime
	    t.change :end_at, :datetime
	  end
	end
end
