class ChangeLanguagesDefaultToEnglishInProfile < ActiveRecord::Migration
	def up
		change_column_default :profiles, :languages, 'English'
	end

	def down
		change_column_default :profiles, :languages, nil
	end
end
