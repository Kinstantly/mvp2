class RenameAuthorizationAmountToAuthorizedAmountInCustomerFile < ActiveRecord::Migration
	def change
		rename_column :customer_files, :authorization_amount, :authorized_amount
	end
end
