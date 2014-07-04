class String
	def to_alphanumeric
		self.gsub(/[^A-Za-z0-9]/, '_')
	end
	
	def html_escape
		ERB::Util.html_escape self
	end
	
	def to_db_singleton(singleton_class)
		singleton_class.where(name: self).first_or_create
	end
	
	def to_category
		to_db_singleton Category
	end
	
	def to_subcategory
		to_db_singleton Subcategory
	end
	
	def to_service
		to_db_singleton Service
	end
	
	def to_specialty
		to_db_singleton Specialty
	end
	
	def to_search_term
		to_db_singleton SearchTerm
	end
end
