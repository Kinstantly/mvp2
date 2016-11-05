# Null stand-in for a Sunspot search object.
# Return an instance of this when you want to force a null search result.
class NilSearch
	attr_reader :error
	
	def initialize(params = {})
		@error = params[:error]
	end
	
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
