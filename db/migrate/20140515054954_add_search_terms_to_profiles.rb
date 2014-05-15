class AddSearchTermsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :search_terms, :string
  end
end
