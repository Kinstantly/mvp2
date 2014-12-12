class StripeCharge < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe charge record.
	
	after_create :notify_customer
	
	attr_accessor :refund_amount, :refund_reason
	attr_accessible :api_charge_id, :amount, :amount_refunded, :paid, :refunded, :captured, :deleted, :livemode,
		:balance_transaction, :fee, :stripe_fee, :application_fee, :description, :statement_description,
		:refund_amount_usd, :fee_refunded, :stripe_fee_refunded, :application_fee_refunded
	
	belongs_to :stripe_card
	belongs_to :customer_file
	
	scope :all_for_provider, lambda { |provider| joins(:customer_file).where(customer_files: {user_id: provider.id}) }
	
	monetize :amount, as: 'amount_usd', allow_nil: true
	monetize :amount_refunded, as: 'amount_refunded_usd', allow_nil: true
	monetize :stripe_fee, as: 'stripe_fee_usd', allow_nil: true
	monetize :application_fee, as: 'application_fee_usd', allow_nil: true
	monetize :refund_amount, as: 'refund_amount_usd', allow_nil: true
	
	# The following are the difference between the original value and the refunded value, if any.
	monetize :amount_collected, as: 'amount_collected_usd'
	monetize :fee_collected, as: 'fee_collected_usd'
	monetize :stripe_fee_collected, as: 'stripe_fee_collected_usd'
	monetize :application_fee_collected, as: 'application_fee_collected_usd'
	
	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used by other models or at the view layer for character counts.
	MAX_LENGTHS = {
		description: 250,
		statement_description: 15 # See https://stripe.com/docs/api#create_charge
	}
	
	[:description, :statement_description].each do |attribute|
		validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
	end
	
	REFUND_REASONS = [
		'requested_by_customer',
		'duplicate',
		'fraudulent'
	]
	
	def amount_collected
		collected_value_of :amount
	end
	
	def fee_collected
		collected_value_of :fee
	end
	
	def stripe_fee_collected
		collected_value_of :stripe_fee
	end
	
	def application_fee_collected
		collected_value_of :application_fee
	end
	
	def create_refund(options)
		options ||= {}
		self.refund_amount_usd = options[:refund_amount_usd]
		self.refund_reason = options[:refund_reason]
		return false unless refund_is_allowed?
		
		refund_arguments = {
			amount:                 refund_amount,
			refund_application_fee: true,
			expand:                 ['balance_transaction']  # We cannot expand 'charge', unfortunately.
		}
		refund_arguments.merge! reason: refund_reason if refund_reason.present?
		access_token = customer_file.try(:stripe_info).try(:access_token)
		
		# Attempt the refund.
		charge = Stripe::Charge.retrieve api_charge_id, access_token
		refund = charge.refunds.create refund_arguments, access_token
		
		# Get the change in fees.
		balance_transaction = refund.balance_transaction
		fee_details = balance_transaction.fee_details.inject({}) { |detail_hash, detail|
			detail_hash[detail.type] = detail.amount
			detail_hash
		}
		
		# Get the new charge values.
		charge = Stripe::Charge.retrieve api_charge_id, access_token
		
		# Update this record with the new values.
		update_attributes(
			refunded:                 charge.refunded,
			amount_refunded:          charge.amount_refunded,
			fee_refunded:             increment_refund_value(fee_refunded, balance_transaction.fee),
			stripe_fee_refunded:      increment_refund_value(stripe_fee_refunded, fee_details['stripe_fee']),
			application_fee_refunded: increment_refund_value(application_fee_refunded, fee_details['application_fee'])
		)
	rescue Stripe::CardError, Payment::ChargeAuthorizationError, Stripe::InvalidRequestError => error
		errors.add :base, error.message
		false
	rescue ActiveRecord::RecordInvalid => error
		if errors.empty?
			Rails.logger.error "#{self.class} Error: #{error}"
			errors.add :base, I18n.t('payment.contact_support')
		end
		false
	end
	
	private
	
	# Return true if a refund is allowed on this charge.
	def refund_is_allowed?
		not refunded and api_charge_id.present? and amount and refund_amount and refund_amount <= amount and (refund_reason.blank? or REFUND_REASONS.include?(refund_reason))
	end
	
	# Increment value by the negative of the given increment (increment is assumed to be a negative value).
	def increment_refund_value(value, increment)
		if value or increment
			value ||= 0
			increment ||= 0
			value - increment
		else
			nil
		end
	end
	
	# The difference between the original value and the refunded value, if any, of the specified attribute.
	def collected_value_of(attribute)
		amount = send(attribute).presence || 0
		amount_refunded = send(attribute.to_s+'_refunded').presence || 0
		amount - amount_refunded
	end
	
	# If there is a customer, notify them of the new charge.
	def notify_customer
		StripeChargeMailer.notify_customer(self).deliver if customer_file.try(:has_customer_account?)
	end
end
