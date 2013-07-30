class RenameConsultRemotelyOrAtHomeToConsultRemotelyInProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.rename :consult_remotely_or_at_home, :consult_remotely
	end
end
