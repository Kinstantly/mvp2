module SpecialtiesHelper
	def specialty_search_term_to_remove_id(s)
		"search_term_to_remove_#{s.to_s.to_alphanumeric}"
	end
end
