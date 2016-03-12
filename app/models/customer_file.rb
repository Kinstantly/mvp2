class CustomerFile < ActiveRecord::Base
	has_paper_trail # Track changes to each customer file.
	
	attr_accessor :charge_amount, :charge_description, :charge_statement_description, :authorized_amount_increment
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :charge_amount_usd, :charge_description, :charge_statement_description ]
	
	belongs_to :provider, class_name: 'User', foreign_key: 'user_id'
	belongs_to :customer
	belongs_to :stripe_card
	has_many :stripe_charges
	
	# Define maximum length of each string or text attribute in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MAX_LENGTHS = {
		charge_description: StripeCharge::MAX_LENGTHS[:description],
		charge_statement_description: StripeCharge::MAX_LENGTHS[:statement_description]
	}
	[:charge_description, :charge_statement_description].each do |attribute|
		validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
	end
	
	monetize :authorized_amount, as: 'authorized_amount_usd', allow_nil: true
	monetize :authorized_amount_increment, as: 'authorized_amount_increment_usd', allow_nil: true
	monetize :charge_amount, as: 'charge_amount_usd', allow_nil: true
	
	validates :authorized_amount, numericality: {only_integer: true, greater_than_or_equal_to: 0}, allow_blank: true
	validates :charge_amount, :authorized_amount_increment, numericality: {only_integer: true, greater_than: 0}, allow_blank: true
	
	before_update :increment_authorized_amount
	
	def create_charge(attribute_values)
		assign_attributes attribute_values
		return false unless charge_is_allowed?
		
		application_fee = if payment_application_fee_percentage
			(charge_amount.to_i * payment_application_fee_percentage / 100).to_i
		else
			nil
		end
		
		stripe_customer = customer.stripe_customer
		access_token = provider.stripe_info.access_token
		
		# Create a token from the existing customer on the application's account.
		# Use the customer's default card.
		# (Later when we implement multiple cards per customer, the customer will choose a card to use with this customer_file.)
		# Do the charge on the provider's behalf by using their access token from the Stripe Connect flow.
		card_token = Stripe::Token.create(
			{
				customer: stripe_customer.api_customer_id,
				card:     stripe_card.api_card_id
			},
			access_token
		)
		
		# Do the charge using the single-use token and the provider's access token.
		charge_parameters = {
			card:                  card_token.id,
			amount:                charge_amount.to_i,
			currency:              'usd',
			application_fee:       application_fee
		}
		charge_parameters[:description] = charge_description if charge_description.present?
		# Use the statement_descriptor API attribute. It should only be set if we have a value.
		charge_parameters[:statement_descriptor] = charge_statement_description if charge_statement_description.present?
		charge = Stripe::Charge.create(charge_parameters, access_token)
		
		# Get the fees.
		balance_transaction = Stripe::BalanceTransaction.retrieve charge.balance_transaction, access_token
		fee_details = balance_transaction.fee_details.inject({}) { |detail_hash, detail|
			detail_hash[detail.type] = detail.amount
			detail_hash
		}
		
		# Store the charge information locally.
		stripe_charge = stripe_card.stripe_charges.build(
			api_charge_id:         charge.id,
			amount:                charge.amount,
			paid:                  charge.paid,
			captured:              charge.captured,
			livemode:              charge.livemode,
			description:           charge.description,
			statement_description: charge.statement_descriptor, # API attribute is now named statement_descriptor
			balance_transaction:   charge.balance_transaction,
			fee:                   balance_transaction.fee,
			stripe_fee:            fee_details['stripe_fee'],
			application_fee:       fee_details['application_fee']
		)
		stripe_charges << stripe_charge
		
		self.authorized_amount -= charge.amount
		save!
		
		true
	rescue Stripe::CardError, Payment::ChargeAuthorizationError, Stripe::InvalidRequestError => error
		errors.add :base, error.message
		false
	rescue ActiveRecord::RecordInvalid, Stripe::AuthenticationError => error
		Rails.logger.error "#{self.class} Error: #{error}"
		if errors.empty?
			errors.add :base, I18n.t('payment.contact_support')
		end
		false
	end
	
	def stripe_info
		provider.try :stripe_info
	end
	
	def customer_user
		customer.try(:user)
	end
	
	def customer_email
		customer_user.try(:email)
	end
	
	def customer_username
		customer_user.try(:username)
	end
	
	def customer_name
		customer_username.presence or customer_email
	end
	
	def has_customer_account?
		customer_user.present?
	end
	
	# Use this boolean method to determine whether this customer_file can be used to collect a payment.
	# Checks all of the following:
	# * The "authorized" flag is true.
	# * There is a minimum authorized amount.
	# * Customer and user records are attached, i.e., neither has been deleted.
	def customer_has_authorized_payment?
		authorized and authorized_amount.try(:>, 0) and has_customer_account?
	end
	
	def provider_name
		provider.try(:profile).try(:company_otherwise_display_name)
	end
	
	def confirm_authorized_amount
		CustomerMailer.confirm_authorized_amount(self).deliver
	end
	
	def notify_provider_of_payment_authorization
		CustomerMailer.notify_provider_of_payment_authorization(self).deliver
	end
	
	def confirm_revoked_authorization
		CustomerMailer.confirm_revoked_authorization(self).deliver
	end
	
	def notify_provider_of_revoked_authorization
		CustomerMailer.notify_provider_of_revoked_authorization(self).deliver
	end
	
	private
	
	# Use this boolean method to determine whether the charge_amount can be collected.
	# Also ensures that the customer still exists and has authorized payment to this provider.
	def charge_is_allowed?
		if not customer_has_authorized_payment?
			errors.add :base, I18n.t('views.customer_file.new_charge.you_are_not_authorized')
			false
		elsif valid? and charge_amount.present? and authorized_amount and charge_amount.to_i <= authorized_amount
			true
		else
			errors.add :charge_amount, I18n.t('views.customer_file.new_charge.invalid', amount: charge_amount_usd) if errors.empty?
			false
		end
	end
	
	def increment_authorized_amount
		self.authorized_amount += authorized_amount_increment.to_i if authorized_amount && authorized_amount_increment
		true
	end
end
