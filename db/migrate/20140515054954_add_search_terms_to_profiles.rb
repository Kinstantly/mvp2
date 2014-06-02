class AddSearchTermsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :search_terms, :text
  end
end
