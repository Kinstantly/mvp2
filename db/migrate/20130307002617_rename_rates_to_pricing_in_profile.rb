class RenameRatesToPricingInProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.rename :rates, :pricing
	end
end
