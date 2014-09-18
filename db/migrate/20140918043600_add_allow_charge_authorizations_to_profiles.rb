class AddAllowChargeAuthorizationsToProfiles < ActiveRecord::Migration
	def change
		add_column :profiles, :allow_charge_authorizations, :boolean, default: false
	end
end
