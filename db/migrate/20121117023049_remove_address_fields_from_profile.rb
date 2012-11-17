class RemoveAddressFieldsFromProfile < ActiveRecord::Migration
	change_table :profiles do |t|
		t.remove :address1
		t.remove :address2
		t.remove :city
		t.remove :region
		t.remove :country
		t.remove :postal_code
	end
end
