class CreateRefundValidator < ActiveModel::EachValidator
	MESSAGE_SCOPE = 'activerecord.errors.models.stripe_charge'
	
	def validate_each(record, attribute, value)
		record.errors.add :base, message('already_refunded') if record.refunded
		record.errors[:amount] << message('attributes.amount.blank') unless record.amount.try(:>, 0)
		record.errors[attribute] << message("attributes.#{attribute}.blank") unless value.try(:>, 0)
		if record.errors.empty?
			record.errors[attribute] << message("attributes.#{attribute}.greater_than", count: record.amount_collected_usd.format) if value > record.amount_collected
		end
	end
	
	private
	
	def message(key, parameters={})
		options[:message] || I18n.t(key, parameters.merge(scope: MESSAGE_SCOPE))
	end
end
