class AddOfficePhoneVideoHoursAcceptingNewClientsToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :office_hours, :text
		add_column :profiles, :phone_hours, :text
		add_column :profiles, :video_hours, :text
		add_column :profiles, :accepting_new_clients, :boolean, default: true
	end
end
