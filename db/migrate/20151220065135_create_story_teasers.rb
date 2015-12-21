class CreateStoryTeasers < ActiveRecord::Migration
	def change
		create_table :story_teasers do |t|
			t.boolean :active
			t.integer :display_order
			t.string :url
			t.string :image_file
			t.string :title
			t.string :css_class

			t.timestamps
		end
		
		add_index :story_teasers, [:active, :display_order]
	end
end
