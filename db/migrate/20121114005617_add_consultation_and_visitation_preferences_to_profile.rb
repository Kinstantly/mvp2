class AddConsultationAndVisitationPreferencesToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :consult_by_email, :boolean
    add_column :profiles, :consult_by_phone, :boolean
    add_column :profiles, :consult_by_video, :boolean
    add_column :profiles, :visit_home, :boolean
    add_column :profiles, :visit_school, :boolean
  end
end
