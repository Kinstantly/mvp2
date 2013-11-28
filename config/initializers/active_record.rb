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
	
	def lower_case_name
		name.try :downcase
	end
	
	# Return the human name for the attribute if its value is present.
	def human_attribute_name_if_present(attribute)
		send(attribute).present? ? self.class.human_attribute_name(attribute) : nil
	end
	
	# Return an array of human names for any of the attributes whose values are present.
	def human_attribute_names_if_present(*attributes)
		attributes.map do |attribute|
			human_attribute_name_if_present attribute
		end.compact
	end
	
	private
	
	def remove_blanks(strings)
		(strings || []).select(&:present?)
	end
	
	def remove_blanks_and_strip(strings)
		remove_blanks(strings).map &:strip
	end
	
	# Display area code, number, and if present, extension.
	# Display country code if so designated.
	def display_phone_number(value, show_country_code=false)
		phone = Phonie::Phone.parse value.try(:strip)
		phone.try :format, "#{'%c ' if show_country_code}(%a) %f-%l#{', x%x' if phone.try(:extension).present?}"
	end
end
