class AddSignedUpFromBlogAndPostalCodeToUser < ActiveRecord::Migration
	def change
		add_column :users, :signed_up_from_blog, :boolean, default: false
		add_column :users, :postal_code, :string
	end
end
