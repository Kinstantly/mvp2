class CreateSubscriptions < ActiveRecord::Migration
	def change
		create_table :subscriptions do |t|
			t.boolean :subscribed
			t.string :status
			t.string :list_id
			t.string :subscriber_hash
			t.string :unique_email_id
			t.string :email
			t.string :fname
			t.string :lname
			t.date :birth1
			t.date :birth2
			t.date :birth3
			t.date :birth4
			t.string :zip_code
			t.string :postal_code
			t.string :country
			t.string :subsource

			t.timestamps null: false
		end
		add_index :subscriptions, :subscribed
		add_index :subscriptions, :list_id
	end
end
