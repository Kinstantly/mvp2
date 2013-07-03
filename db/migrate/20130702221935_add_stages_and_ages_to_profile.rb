class AddStagesAndAgesToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :adoption_stage, :boolean
		add_column :profiles, :preconception_stage, :boolean
		add_column :profiles, :pregnancy_stage, :boolean
		add_column :profiles, :ages, :string
	end
end
