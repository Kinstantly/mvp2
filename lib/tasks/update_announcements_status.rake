namespace :announcements do
	desc "Determine announcement active status based on their date range and update their status accordingly"
	task :update_active_status => :environment do
		Announcement.all.each do |announcement|
			now = DateTime.now
			if announcement.start_at.present? && announcement.start_at <= now && announcement.end_at.present? && announcement.end_at > now
				announcement.active = true
			else
				announcement.active = false
			end
			if announcement.active_changed?
				puts("Announcement #{announcement.id} of profile #{announcement.profile.id}: active status updated from #{announcement.active_was} to #{announcement.active}.")
			end
			announcement.save
		end
	end

end
