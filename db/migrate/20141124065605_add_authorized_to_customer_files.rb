class AddAuthorizedToCustomerFiles < ActiveRecord::Migration
	def change
		add_column :customer_files, :authorized, :boolean, default: true
	end
end
