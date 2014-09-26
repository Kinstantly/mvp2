class CustomerFile < ActiveRecord::Base
	has_paper_trail # Track changes to each customer file.
	
	attr_accessor :charge_amount, :charge_description, :charge_statement_description
	attr_accessible :charge_amount, :charge_description, :charge_statement_description
	
	belongs_to :provider, class_name: 'User', foreign_key: 'user_id'
	belongs_to :customer
	
	validates :authorization_amount, numericality: {only_integer: true, greater_than_or_equal_to: 0}, allow_blank: true
	validates :charge_amount, numericality: {only_integer: true, greater_than: 0}, allow_blank: true
	
	def create_charge(attribute_values)
		assign_attributes attribute_values
		return false unless charge_amount_is_valid?
		
		application_fee = (charge_amount.to_i * 2 / 100).to_i
		
		api_customer_id = customer.stripe_customer.api_customer_id
		# api_card_id = stripe_card.api_card_id
		access_token = provider.stripe_info.access_token
		
		# Create a token from the existing customer on the application's account.
		# Use the customer's default card.
		# (Later when we implement multiple cards per customer, the customer will choose a card to use with this customer_file.  Then do {customer: api_customer_id, card: api_card_id}.)
		# Do the charge on the provider's behalf by using their access token from the Stripe Connect flow.
		card_token = Stripe::Token.create(
			{customer: api_customer_id},
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
		
		self.authorization_amount -= charge.amount
		save!
		
		true
	rescue Stripe::CardError, Payment::ChargeAuthorizationError, Stripe::InvalidRequestError => error
		errors.add :base, error.message
		false
	rescue ActiveRecord::RecordInvalid => error
		errors.add :base, I18n.t('payment.contact_support') if errors.empty?
		errors.add :log_message, error.message
		false
	end
	
	private
	
	def charge_amount_is_valid?
		if valid? and charge_amount.present? and authorization_amount and charge_amount.to_i <= authorization_amount
			true
		else
			errors.add :charge_amount, "is invalid: #{charge_amount}"
			false
		end
	end
end
