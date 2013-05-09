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
	
	# Display area code, number, and if present, extension.
	# Display country code if so designated.
	def display_phone_number(value, show_country_code=false)
		phone = Phonie::Phone.parse value.try(:strip)
		phone.try :format, "#{'%c ' if show_country_code}(%a) %f-%l#{', x%x' if phone.try(:extension).present?}"
	end
end
