class PhoneNumberValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		unless Phonie::Phone.valid?(value) # Default country code is set in config/application.rb.
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.invalid_phone_number'))
		end
	end
end
