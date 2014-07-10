class AddRegistrationSpecialCodeToUsers < ActiveRecord::Migration
	def change
		add_column :users, :registration_special_code, :string
	end
end
