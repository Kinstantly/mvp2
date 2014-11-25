class CustomerFile < ActiveRecord::Base
	has_paper_trail # Track changes to each customer file.
	
	attr_accessor :charge_amount, :charge_description, :charge_statement_description, :authorized_amount_increment
	attr_accessible :charge_amount_usd, :charge_description, :charge_statement_description
	
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
		
		application_fee = (charge_amount.to_i * 2 / 100).to_i
		
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
		charge = Stripe::Charge.create(
			{
				card:                  card_token.id,
				amount:                charge_amount.to_i,
				currency:              'usd',
				description:           charge_description,
				statement_description: charge_statement_description,
				application_fee:       application_fee
			},
			access_token
		)
		
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
			statement_description: charge.statement_description,
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
	rescue ActiveRecord::RecordInvalid => error
		if errors.empty?
			Rails.logger.error "#{self.class} Error: #{error}"
			errors.add :base, I18n.t('payment.contact_support')
		end
		false
	end
	
	def customer_email
		customer.try(:user).try(:email)
	end
	
	def customer_username
		customer.try(:user).try(:username)
	end
	
	def customer_name
		customer_username.presence or customer_email
	end
	
	private
	
	def charge_is_allowed?
		if not authorized
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
