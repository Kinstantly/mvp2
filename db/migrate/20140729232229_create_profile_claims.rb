class CreateProfileClaims < ActiveRecord::Migration
  def change
	create_table :profile_claims do |t|
	 	t.integer :profile_id
		t.integer :claimant_id
		t.string :claimant_email
		t.string :claimant_phone
		t.text :admin_notes

		t.timestamps
	end
  end
end
