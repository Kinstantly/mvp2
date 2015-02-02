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

	# Return the provider (User) associated with the given profile ID only if that provider is allowed to make charges.
	def provider_for_profile(id)
		Profile.find(id.to_i).payable_provider || 
			raise(Payment::ChargeAuthorizationError, I18n.t('payment.provider_not_allowed_charge_authorizations'))
	end
	
	def authorized_for_profile(id)
		if persisted?
			customer_files.for_provider(provider_for_profile(id)).try(:authorized)
		else
			false
		end
	end
	
	def authorized_amount_for_profile(id)
		if persisted?
			customer_files.for_provider(provider_for_profile(id)).try(:authorized_amount_usd)
		else
			nil
		end
	end
	
	def card_for_provider(provider)
		customer_files.for_provider(provider).try(:stripe_card)
	end
	
	def save_with_authorization(options={})
		self.user ||= options[:user] if options[:user]
		
		# Make sure we have a permissible provider. Raises error if not.
		provider = provider_for_profile options[:profile_id] 
		providers << provider unless providers.include?(provider)
		
		stripe_card = nil # Initialize for first card or changing the card.
		
		if not stripe_customer # First time for this customer.
			customer = Stripe::Customer.create(
				email: user.try(:email),
				card:  options[:stripe_token],
				description: 'Kinstantly provider customer'
			)
		
			build_stripe_customer(
				api_customer_id: customer.id,
				description: customer.description,
				livemode: customer.livemode
			)

			card = customer.cards.retrieve customer.default_card
			stripe_card = stripe_customer.stripe_cards.build(
				api_card_id: card.id,
				brand: card.brand,
				funding: card.funding,
				exp_month: card.exp_month,
				exp_year: card.exp_year,
				last4: card.last4,
				livemode: customer.livemode
			)

		elsif options[:stripe_token].present? # Adding a new card.
			customer = stripe_customer.retrieve
			card = customer.cards.create card: options[:stripe_token]

			stripe_card = stripe_customer.stripe_cards.create(
				api_card_id: card.id,
				brand: card.brand,
				funding: card.funding,
				exp_month: card.exp_month,
				exp_year: card.exp_year,
				last4: card.last4,
				livemode: stripe_customer.livemode
			)
		end

		# Save *after* we're sure all the Stripe API calls succeeded.
		save!

		# Note: customer_file was created by save because provider was added via the 'has_many through' association.
		customer_file = customer_files.for_provider(provider)
		customer_file.stripe_card = stripe_card if stripe_card
		customer_file.authorized = options[:authorized] unless options[:authorized].nil? # Boolean value.
		customer_file.authorized_amount_usd = options[:amount] if options[:amount].present?
		customer_file.authorized_amount_increment_usd = options[:amount_increment] if options[:amount_increment].present?
		customer_file.save!
		
		# Notify the customer and provider.
		if customer_file.authorized
			customer_file.confirm_authorized_amount
			customer_file.notify_provider_of_payment_authorization
		elsif not options[:authorized].nil?
			customer_file.confirm_revoked_authorization
			customer_file.notify_provider_of_revoked_authorization
		end
		
		true
	rescue Stripe::CardError, Payment::ChargeAuthorizationError => error
		errors.add :base, error.message
		false
	rescue ActiveRecord::RecordInvalid => error
		customer_file.errors.full_messages.each do |message|
			errors.add :base, message
		end
		# errors.add :base, error.message if errors.empty?
		false
	rescue Stripe::InvalidRequestError, Stripe::AuthenticationError => error
		Rails.logger.error "#{self.class} Error: #{error}"
		if errors.empty?
			errors.add :base, I18n.t('payment.contact_support')
		end
		false
	end
end
