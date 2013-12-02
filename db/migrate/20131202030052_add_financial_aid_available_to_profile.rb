class AddFinancialAidAvailableToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :financial_aid_available, :boolean, default: false
	end
end
