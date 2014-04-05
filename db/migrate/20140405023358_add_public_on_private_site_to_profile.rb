class AddPublicOnPrivateSiteToProfile < ActiveRecord::Migration
	def change
		add_column :profiles, :public_on_private_site, :boolean, default: false
	end
end
