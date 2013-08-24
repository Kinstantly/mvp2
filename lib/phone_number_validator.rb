class PhoneNumberValidator < ActiveModel::EachValidator
	MAX_LENGTH = 50
	
	def validate_each(record, attribute, value)
		if value.blank?
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.blank'))
		else
			unless Phonie::Phone.valid?(value) # Default country code is set in config/application.rb.
				record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.invalid_phone_number'))
			end
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.too_long', count: MAX_LENGTH)) if value.length > MAX_LENGTH
		end
	end
end
