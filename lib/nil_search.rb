# Null stand-in for a Sunspot search object.
# Return an instance of this when you want to force a null search result.
class NilSearch
	def results
		[]
	end
	
	def total
		0
	end
	
	def query
		nil
	end
end
