module HomeHelper
	def home_column_categories(col)
		case col
		when 1
			Category.where('display_order < 10').display_order
		else
			Category.where('display_order >= 10').display_order
		end
	end
end
