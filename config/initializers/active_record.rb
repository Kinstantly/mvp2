class ActiveRecord::Base
	def join_present_attrs(separator=' ', *attrs)
		attrs.map { |attr|
				self.try(attr).presence
			}.compact.join(separator)
	end
end
