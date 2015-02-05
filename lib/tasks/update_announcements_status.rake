namespace :announcements do
	desc "Determine announcement active status based on their date range and update their status accordingly"
	task :update_active_status => :environment do
		Announcement.find_each do |announcement|
			now = DateTime.now
			active_start_date =  announcement.start_at.present? && announcement.start_at <= now
			active_end_date = announcement.end_at.blank? || announcement.end_at >= now
			if active_start_date && active_end_date
				announcement.active = true
			else
				announcement.active = false
			end
			if announcement.active_changed?
				puts("Announcement #{announcement.id} of profile #{announcement.profile.id}: active status updated from #{announcement.active_was} to #{announcement.active}.")
				announcement.save
			end
		end
	end

end
