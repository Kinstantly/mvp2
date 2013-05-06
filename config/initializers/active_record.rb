class ActiveRecord::Base
	def join_present_attrs(separator=' ', *attrs)
		attrs.map { |attr|
				self.try(attr).presence
			}.compact.join(separator)
	end
	
	def errorfree
		@errorfree ||= begin
			errors.present? && persisted? ? self.class.find(id) : self
		rescue ActiveRecord::RecordNotFound
			self
		end
	end
	
	private
	
	# Display country code, area code, number, and if present, extension.
	def display_phone_number(value)
		phone = Phonie::Phone.parse value.try(:strip)
		phone.try :format, '%c (%a) %f-%l' + (phone.try(:extension).present? ? ', x%x' : '')
	end
end
