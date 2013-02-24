class PhoneNumberValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		unless Phonie::Phone.valid?(value) # Default country code is set in config/application.rb.
			record.errors[attribute] << (options[:message] || I18n.t('models.phone_number.invalid'))
		end
	end
end
