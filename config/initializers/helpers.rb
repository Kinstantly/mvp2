class String
	def to_alphanumeric
		self.gsub(/[^A-Za-z0-9]/, '_')
	end
	
	def to_db_singleton(singleton_class)
		singleton_class.find_by_name(self).presence || singleton_class.create(name: self)
	end
	
	def to_category
		to_db_singleton Category
	end
	
	def to_specialty
		to_db_singleton Specialty
	end
end
