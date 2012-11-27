class String
	def to_alphanumeric
		self.gsub(/[^A-Za-z0-9]/, '_')
	end
	
	def to_db_singleton(singleton_class)
		singleton_class.where(name: self).first_or_create
	end
	
	def to_category
		to_db_singleton Category
	end
	
	def to_specialty
		to_db_singleton Specialty
	end
end
