class AddTitleAndGoodToKnowToReview < ActiveRecord::Migration
	def change
		add_column :reviews, :title, :string
		add_column :reviews, :good_to_know, :text
	end
end
