class AddFeesHoursCheckBoxesToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :evening_hours_available, :boolean, default: false
		add_column :profiles, :weekend_hours_available, :boolean, default: false
		add_column :profiles, :free_initial_consult,    :boolean, default: false
		add_column :profiles, :sliding_scale_available, :boolean, default: false
	end
end
