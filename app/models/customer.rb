class Customer < ActiveRecord::Base
	has_paper_trail # Track changes to each provider-customer record.
	
	# attr_accessible 
	
	belongs_to :user
	has_many :providers, class_name: 'User', through: :customer_files
	has_many :customer_files do
		def for_provider(provider)
			where(user_id: provider).first
		end
	end
	has_one :stripe_customer
	
	validates :user, presence: true
	
	def save_with_authorization(options={})
		self.user ||= options[:user]
		
		profile = Profile.find options[:profile_id]
		if profile.try(:allow_charge_authorizations) and (provider = profile.user) and provider.stripe_info
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
			description: 'payment authorization',
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

		save!

		customer_file = customer_files.for_provider(provider)
		customer_file.authorization_amount = options[:amount]
		customer_file.save!
		
		true
	rescue Stripe::CardError, Payment::ChargeAuthorizationError, ActiveRecord::RecordInvalid => error
		errors.add :base, error.message
		false
	end
end
