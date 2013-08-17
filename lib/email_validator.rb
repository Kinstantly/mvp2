class EmailValidator < ActiveModel::EachValidator
	MAX_LENGTH = 200
	
	def validate_each(record, attribute, value)
		if value.blank?
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.blank'))
		else
			unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
				record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.invalid_email'))
			end
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.too_long', count: MAX_LENGTH)) if value.length > MAX_LENGTH
		end
	end
end
