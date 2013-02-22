class PhoneNumberValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		unless Phonie::Phone.valid?(value) # Default country code is set in config/application.rb.
			record.errors[attribute] << (options[:message] || 'must be properly formatted, e.g., "(800) 555-1234"')
		end
	end
end
