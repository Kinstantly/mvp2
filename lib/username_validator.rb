class UsernameValidator < ActiveModel::EachValidator
	MIN_LENGTH = 4
	MAX_LENGTH = 50
	
	def validate_each(record, attribute, value)
		if value.blank?
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.blank'))
		else
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.too_short', count: MIN_LENGTH)) if value.length < MIN_LENGTH
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.too_long', count: MAX_LENGTH)) if value.length > MAX_LENGTH
			record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.not_alphanumeric')) unless value =~ /\A[a-z0-9_]+\z/i
		end
	end
end
