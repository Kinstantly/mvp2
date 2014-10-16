class EmailSubscriptionValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		if value and record.contact_is_blocked?
			message = options[:message] || I18n.t('activerecord.errors.messages.contact_is_blocked', support_email: SUPPORT_EMAIL)
			record.errors[:base] << message unless record.errors[:base].include?(message)
		end
	end
end
