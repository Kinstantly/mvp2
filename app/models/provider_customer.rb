class ProviderCustomer < ActiveRecord::Base
	has_paper_trail # Track changes to each provider-customer record.
	
	# attr_accessible 
	
	belongs_to :user
	has_and_belongs_to_many :providers, class_name: 'User', join_table: 'provider_customers_providers'
	has_one :stripe_customer
	
	validates :user, presence: true
	
	def create_customer_with_card(options={})
		self.user ||= options[:user]
		
		profile = Profile.find options[:profile_id]
		if profile.try(:allow_charge_authorizations) and (provider = profile.user)
			providers << provider unless providers.include?(provider)
		else
			raise Payment::ChargeAuthorizationError, I18n.t('payment.provider_not_allowed_charge_authorizations')
		end
		
		customer = Stripe::Customer.create(
			email: user.try(:email),
			card:  options[:stripe_token],
			description: 'Kinstantly provider customer'
		)
		
		stripe_customer = build_stripe_customer(
			api_customer_id: customer.id,
			description: customer.description,
			livemode: customer.livemode
		)

		charge = Stripe::Charge.create(
			customer:    customer.id,
			amount:      options[:amount],
			capture:     options[:capture].present?, # Important! By default, we do NOT want to debit the card.
			description: 'Provider customer charge authorization',
			currency:    'usd'
		)
		card = charge.card
		
		stripe_card = stripe_customer.stripe_cards.build(
			api_card_id: card.id,
			livemode: charge.livemode
		)
		
		stripe_charge = stripe_card.stripe_charges.build(
			api_charge_id: charge.id,
			amount:        charge.amount,
			paid:          charge.paid,
			captured:      charge.captured,
			livemode:      charge.livemode
		)

		save
		
	rescue Stripe::CardError, Payment::ChargeAuthorizationError => error
		errors.add :base, error.message
	end
end
