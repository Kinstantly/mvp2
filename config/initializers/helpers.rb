class String
	def to_alphanumeric
		self.gsub(/[^A-Za-z0-9]/, '_')
	end
end
